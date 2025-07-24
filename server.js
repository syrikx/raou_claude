const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');
const cheerio = require('cheerio');
const prettier = require('prettier');

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
app.post('/raou/post_coupang', async (req, res) => {
  try {
    console.log('📥 새로운 HTML 캡처 요청 수신');
    
    const {
      timestamp,
      url,
      html_content,
      source,
      app_version,
      user_agent,
      capture_mode
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
    console.log(`  - 캡처 모드: ${capture_mode || 'full_html'} ${capture_mode === 'product_sections' ? '📦 (핵심 정보만)' : '📄 (전체 HTML)'}`);
    
    // 파일명 생성 (타임스탬프 기반)
    const safeTimestamp = timestamp.replace(/[:\-\.]/g, '_');
    const fileName = `coupang_${safeTimestamp}.json`;
    const filePath = path.join(DATA_DIR, fileName);
    
    // HTML 콘텐츠 이스케이프 복원 (순서 중요!)
    const decodedHtml = html_content
      // 1. 백슬래시 이스케이프 먼저 처리
      .replace(/\\\\/g, '\\')        // \\\\ → \\
      .replace(/\\"/g, '"')          // \\\" → \"
      .replace(/\\'/g, "'")          // \\\' → \'
      .replace(/\\n/g, '\n')         // \\n → 개행
      .replace(/\\r/g, '\r')         // \\r → 캐리지 리턴
      .replace(/\\t/g, '\t')         // \\t → 탭
      // 2. 유니코드 이스케이프 처리
      .replace(/\\u003C/g, '<')      // \\u003C → <
      .replace(/\\u003E/g, '>')      // \\u003E → >
      .replace(/\\u0026/g, '&')      // \\u0026 → &
      .replace(/\\u0027/g, "'")      // \\u0027 → '
      .replace(/\\u0022/g, '"')      // \\u0022 → "
      .replace(/\\u002F/g, '/')      // \\u002F → /
      .replace(/\\u003D/g, '=')      // \\u003D → =
      .replace(/\\u0020/g, ' ')      // \\u0020 → 공백
      .replace(/\\u000A/g, '\n')     // \\u000A → 개행
      .replace(/\\u000D/g, '\r');    // \\u000D → 캐리지 리턴
    
    console.log(`📝 HTML 디코딩: ${html_content.length} → ${decodedHtml.length} characters`);
    
    // HTML 구조 분석 및 포맷팅
    const htmlAnalysis = await analyzeAndFormatHtml(decodedHtml);
    
    // 저장할 데이터 구조화
    const dataToSave = {
      metadata: {
        saved_at: new Date().toISOString(),
        file_name: fileName,
        html_size: decodedHtml.length,
        html_size_original: html_content.length,
        html_size_formatted: htmlAnalysis.formatted_html.length,
        url_domain: new URL(url).hostname,
        decoded: true,
        structured: true,
        html_stats: htmlAnalysis.stats
      },
      request_data: {
        timestamp,
        url,
        source,
        app_version,
        user_agent,
        capture_mode: capture_mode || 'full_html'
      },
      html_analysis: htmlAnalysis,
      html_content: decodedHtml,
      original_html_content: html_content // 원본도 보관
    };
    
    // JSON 파일로 저장
    await fs.writeFile(filePath, JSON.stringify(dataToSave, null, 2), 'utf8');
    
    console.log(`✅ 파일 저장 완료: ${fileName}`);
    
    // 성공 응답
    res.status(201).json({
      success: true,
      message: `HTML 캡처가 성공적으로 저장되었습니다 (${capture_mode === 'product_sections' ? '핵심 정보 추출' : '전체 HTML'} 모드)`,
      data: {
        file_name: fileName,
        saved_at: dataToSave.metadata.saved_at,
        html_size: decodedHtml.length,
        html_size_original: html_content.length,
        capture_mode: capture_mode || 'full_html',
        decoded: true,
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
app.get('/raou/list', async (req, res) => {
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
app.get('/raou/view/:filename', async (req, res) => {
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
app.get('/raou/health', (req, res) => {
  res.json({
    success: true,
    message: 'Coupang HTML Capture Server is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    data_directory: DATA_DIR
  });
});

// 루트 경로
app.get('/raou', (req, res) => {
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

// HTML 구조 분석 및 포맷팅 함수
async function analyzeAndFormatHtml(htmlContent) {
  try {
    console.log('🔍 HTML 구조 분석 시작...');
    
    // Cheerio로 HTML 파싱
    const $ = cheerio.load(htmlContent, {
      withDomLvl1: true,
      normalizeWhitespace: false,
      xmlMode: false,
      decodeEntities: true
    });
    
    // HTML 구조 통계 수집
    const stats = {
      total_elements: $('*').length,
      head_elements: $('head *').length,
      body_elements: $('body *').length,
      div_count: $('div').length,
      span_count: $('span').length,
      a_count: $('a').length,
      img_count: $('img').length,
      script_count: $('script').length,
      style_count: $('style').length,
      form_count: $('form').length,
      input_count: $('input').length,
      button_count: $('button').length,
      table_count: $('table').length,
      unique_classes: [...new Set($('[class]').map((i, el) => $(el).attr('class')).get())].length,
      unique_ids: [...new Set($('[id]').map((i, el) => $(el).attr('id')).get())].length
    };
    
    // 구조적 정보 추출
    const structure = {
      doctype: htmlContent.includes('<!DOCTYPE') ? 'HTML5' : 'Legacy',
      has_head: $('head').length > 0,
      has_body: $('body').length > 0,
      title: $('title').text() || '',
      meta_tags: $('meta').map((i, el) => ({
        name: $(el).attr('name'),
        content: $(el).attr('content'),
        property: $(el).attr('property')
      })).get(),
      stylesheets: $('link[rel="stylesheet"]').map((i, el) => $(el).attr('href')).get(),
      scripts: $('script[src]').map((i, el) => $(el).attr('src')).get()
    };
    
    // 주요 섹션별 내용 추출
    const sections = {
      head_content: $('head').html() || '',
      body_start: $('body').children().first().prop('outerHTML') || '',
      main_divs: $('body > div').map((i, el) => ({
        index: i,
        id: $(el).attr('id') || '',
        class: $(el).attr('class') || '',
        tag_name: el.tagName,
        children_count: $(el).children().length,
        text_length: $(el).text().length
      })).get(),
      navigation: $('nav, .nav, .navigation, .menu').map((i, el) => ({
        tag: el.tagName,
        class: $(el).attr('class') || '',
        links: $(el).find('a').length
      })).get(),
      forms: $('form').map((i, el) => ({
        action: $(el).attr('action') || '',
        method: $(el).attr('method') || 'get',
        inputs: $(el).find('input').length
      })).get()
    };
    
    // Prettier로 HTML 포맷팅
    let formattedHtml;
    try {
      formattedHtml = await prettier.format(htmlContent, {
        parser: 'html',
        tabWidth: 2,
        useTabs: false,
        printWidth: 100,
        htmlWhitespaceSensitivity: 'css',
        endOfLine: 'lf'
      });
    } catch (prettierError) {
      console.warn('⚠️ Prettier 포맷팅 실패, 원본 사용:', prettierError.message);
      formattedHtml = htmlContent;
    }
    
    // 별도 HTML 파일로도 저장
    const htmlFileName = `formatted_${Date.now()}.html`;
    const htmlFilePath = path.join(DATA_DIR, htmlFileName);
    await fs.writeFile(htmlFilePath, formattedHtml, 'utf8');
    
    console.log('✅ HTML 구조 분석 완료');
    console.log(`📊 통계: ${stats.total_elements}개 요소, ${stats.div_count}개 div, ${stats.script_count}개 script`);
    
    return {
      stats,
      structure,
      sections,
      formatted_html: formattedHtml,
      formatted_file: htmlFileName,
      analysis_timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error('❌ HTML 분석 중 오류:', error);
    return {
      error: error.message,
      stats: { total_elements: 0 },
      structure: {},
      sections: {},
      formatted_html: htmlContent,
      formatted_file: null,
      analysis_timestamp: new Date().toISOString()
    };
  }
}

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