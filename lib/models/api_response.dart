class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  const ApiResponse.loading() : this(isLoading: true);

  const ApiResponse.success(T data) : this(data: data, isSuccess: true);

  const ApiResponse.error(String error) : this(error: error);

  bool get hasError => error != null;
  bool get hasData => data != null;
}