module ApiAuthPatch
  def calculated_hash
    if @request.respond_to?(:body_stream) && @request.body_stream
      body = @request.body_stream.read
      @request.body_stream.rewind
    else
      body = @request.body
    end

    content_md5_fallback? ? md5_base64digest(body || '') : sha256_base64digest(body || '')
  end

  def populate_content_hash
    return unless @request.class::REQUEST_HAS_BODY

    header_name = content_md5_fallback? ? 'Content-MD5' : 'X-Authorization-Content-SHA256'

    @request[header_name] = calculated_hash
  end

  def content_hash
    header_name = content_md5_fallback? ? %w(Content-MD5) : %w(X-Authorization-Content-SHA256)

    find_header(header_name)
  end

  def content_md5_fallback?
    @request['use-md5'] == 'true'
  end
end
ApiAuth::RequestDrivers::NetHttpRequest.prepend(ApiAuthPatch)
