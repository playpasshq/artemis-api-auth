module ApiAuthPatch
  def calculated_hash
    if @request.respond_to?(:body_stream) && @request.body_stream
      body = @request.body_stream.read
      @request.body_stream.rewind
    else
      body = @request.body
    end

    if content_md5_fallback?
      md5_base64digest(body || '')
    else
      sha256_base64digest(body || '')
    end
  end

  def populate_content_hash
    return unless @request.class::REQUEST_HAS_BODY

    header_name = content_md5_fallback? ? 'Content-MD5' : 'X-Authorization-Content-SHA256'
    @request[header_name] = calculated_hash
  end

  def content_md5_fallback?
    @request['Content-MD5'] == 'true'
  end
end
ApiAuth::RequestDrivers::NetHttpRequest.prepend(ApiAuthPatch)
