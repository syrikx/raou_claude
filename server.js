const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = 5000;

// 미들웨어 설정
app.use(cors()); // CORS 허용
app.use(express.json({ limit: '10mb' })); // JSON 파싱 (10MB 제한)
app.use(express.urlencoded({ extended: true }));

// 로그 디렉토리 생성
const DATA_DIR = path.join(__dirname, 'coupang_data');

// 서버 시작 시 데이터 디렉토리 생성
async function initializeServer() {
  try {
    await fs.mkdir(DATA_DIR, { recursive: true });
    console.log(`📁 데이터 디렉토리 생성: ${DATA_DIR}`);
  } catch (error) {
    console.error('❌ 디렉토리 생성 실패:', error);
  }
}

// 메인 엔드포인트: /post_coupang
app.post('/post_coupang', async (req, res) => {
  try {
    console.log('📥 새로운 HTML 캡처 요청 수신');
    
    const {
      timestamp,
      url,
      html_content,
      source,
      app_version,
      user_agent
    } = req.body;
    
    // 요청 데이터 검증
    if (!timestamp || !url || !html_content) {
      return res.status(400).json({
        success: false,
        message: '필수 데이터가 누락되었습니다 (timestamp, url, html_content)',
        received_fields: Object.keys(req.body)
      });
    }
    
    console.log('📊 수신 데이터:');
    console.log(`  - 시간: ${timestamp}`);
    console.log(`  - URL: ${url}`);
    console.log(`  - HTML 크기: ${html_content.length} characters`);
    console.log(`  - 소스: ${source}`);
    console.log(`  - 앱 버전: ${app_version}`);
    console.log(`  - User Agent: ${user_agent}`);
    
    // 파일명 생성 (타임스탬프 기반)
    const safeTimestamp = timestamp.replace(/[:\-\.]/g, '_');
    const fileName = `coupang_${safeTimestamp}.json`;
    const filePath = path.join(DATA_DIR, fileName);
    
    // 저장할 데이터 구조화
    const dataToSave = {
      metadata: {
        saved_at: new Date().toISOString(),
        file_name: fileName,
        html_size: html_content.length,
        url_domain: new URL(url).hostname
      },
      request_data: {
        timestamp,
        url,
        source,
        app_version,
        user_agent
      },
      html_content
    };
    
    // JSON 파일로 저장
    await fs.writeFile(filePath, JSON.stringify(dataToSave, null, 2), 'utf8');
    
    console.log(`✅ 파일 저장 완료: ${fileName}`);
    
    // 성공 응답
    res.status(201).json({
      success: true,
      message: 'HTML 캡처가 성공적으로 저장되었습니다',
      data: {
        file_name: fileName,
        saved_at: dataToSave.metadata.saved_at,
        html_size: html_content.length,
        url: url
      }
    });
    
  } catch (error) {
    console.error('❌ HTML 처리 중 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 내부 오류가 발생했습니다',
      error: error.message
    });
  }
});

// 저장된 파일 목록 조회
app.get('/list', async (req, res) => {
  try {
    const files = await fs.readdir(DATA_DIR);
    const jsonFiles = files.filter(file => file.endsWith('.json'));
    
    const fileList = await Promise.all(
      jsonFiles.map(async (fileName) => {
        const filePath = path.join(DATA_DIR, fileName);
        const stats = await fs.stat(filePath);
        
        try {
          const content = await fs.readFile(filePath, 'utf8');
          const data = JSON.parse(content);
          
          return {
            file_name: fileName,
            created: stats.birthtime,
            size: stats.size,
            url: data.request_data?.url,
            timestamp: data.request_data?.timestamp,
            html_size: data.metadata?.html_size
          };
        } catch (parseError) {
          return {
            file_name: fileName,
            created: stats.birthtime,
            size: stats.size,
            error: 'JSON 파싱 실패'
          };
        }
      })
    );
    
    // 최신순 정렬
    fileList.sort((a, b) => new Date(b.created) - new Date(a.created));
    
    res.json({
      success: true,
      count: fileList.length,
      files: fileList
    });
    
  } catch (error) {
    console.error('❌ 파일 목록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '파일 목록 조회 실패',
      error: error.message
    });
  }
});

// 특정 파일 내용 조회
app.get('/view/:filename', async (req, res) => {
  try {
    const fileName = req.params.filename;
    const filePath = path.join(DATA_DIR, fileName);
    
    // 파일 존재 확인
    const content = await fs.readFile(filePath, 'utf8');
    const data = JSON.parse(content);
    
    res.json({
      success: true,
      data: data
    });
    
  } catch (error) {
    if (error.code === 'ENOENT') {
      res.status(404).json({
        success: false,
        message: '파일을 찾을 수 없습니다'
      });
    } else {
      console.error('❌ 파일 조회 오류:', error);
      res.status(500).json({
        success: false,
        message: '파일 조회 실패',
        error: error.message
      });
    }
  }
});

// 서버 상태 확인
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Coupang HTML Capture Server is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    data_directory: DATA_DIR
  });
});

// 루트 경로
app.get('/', (req, res) => {
  res.json({
    message: 'Coupang HTML Capture Server',
    version: '1.0.0',
    endpoints: {
      'POST /post_coupang': 'HTML 캡처 데이터 저장',
      'GET /list': '저장된 파일 목록 조회',
      'GET /view/:filename': '특정 파일 내용 조회',
      'GET /health': '서버 상태 확인'
    }
  });
});

// 서버 시작
initializeServer().then(() => {
  app.listen(PORT, () => {
    console.log('🚀 Coupang HTML Capture Server 시작!');
    console.log(`📡 서버 주소: http://localhost:${PORT}`);
    console.log('📍 주요 엔드포인트:');
    console.log(`  - POST /post_coupang - HTML 데이터 저장`);
    console.log(`  - GET /list - 파일 목록 조회`);
    console.log(`  - GET /health - 서버 상태 확인`);
    console.log(`📁 데이터 저장 경로: ${DATA_DIR}`);
    console.log('');
    console.log('💡 테스트 방법:');
    console.log(`  curl http://localhost:${PORT}/health`);
  });
});

// 서버 종료 시 정리
process.on('SIGINT', () => {
  console.log('\n🛑 서버를 종료합니다...');
  process.exit(0);
});

process.on('uncaughtException', (error) => {
  console.error('💥 처리되지 않은 예외:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 처리되지 않은 Promise 거부:', reason);
  process.exit(1);
});