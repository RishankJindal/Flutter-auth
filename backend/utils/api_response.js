class ApiResponse {
    constructor(statusCode, msg, data) {
        this.statusCode = statusCode,
            this.msg = msg,
            this.data = data
    }
}

export default ApiResponse;
