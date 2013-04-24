module PagSeguro
  class PaymentSession
    attr_accessor :id, :email, :token, :response

    def initialize(email, token)
      @email = email
      @token = token
    end

    def init_session
      @response ||= parse_payment_session_response
      parse_id
    end

    def parse_payment_session_response
      response = RestClient.post(session_url_without_params, {:token => @token, :email => @email}) { |resp, request, result| resp }
      if response.code == 200
        response.body
      elsif response.code == 401
        raise Errors::Unauthorized
      elsif response.code == 400
        raise Errors::InvalidData.new(response.body)
      else
        raise Errors::UnknownError.new(response)
      end
    end

    def parse_id
      @id = Nokogiri::XML(@response.body).search('//session').at('id').text
    end

    def session_url_without_params
      'https://ws.pagseguro.uol.com.br/v2/sessions'
    end

  end
end