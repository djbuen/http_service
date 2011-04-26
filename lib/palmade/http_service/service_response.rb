module Palmade::HttpService
  class ServiceResponse < Hash
    class UnsupportedResponse < Palmade::HttpService::Error; end

    attr_reader :http_error

    def initialize(resp)
      super()

      @http_error = nil
      set_response(resp)
    end

    def set_response(resp)
      respj = nil

      case resp
      when Palmade::HttpService::Http::Response
        if resp.success?
          respj = resp.json_read
        else
          @http_error = resp.http_error

          respj = {
            'error' => {
              'code' => resp.code,
              'message' => "HTTP Response code %s" % resp.code
            }
          }
        end
      when Hash, String
        respj = resp
      else
        raise UnsupportedResponse, "Unsupported response object #{resp.class.name}"
      end

      case respj
      when nil, ''
        # set nothing
      when Hash
        self.update(respj)
      else
        self[nil] = respj
      end

      self
    end

    def http_error?
      !@http_error.nil?
    end

    def ok?
      error.nil?
    end

    def ok!
      raise_error! if error?
      self
    end

    def raise_error!
      raise ServiceError.new(self)
    end

    def error?
      !error.nil?
    end

    def error
      if self.include?('error')
        self['error']
      else
        nil
      end
    end

    def error_code
      error? ? error['code'] : nil
    end

    def error_message
      error? ? error['message'] : nil
    end

    def error_attachments
      error? ? error['attachments'] : nil
    end
  end
end
