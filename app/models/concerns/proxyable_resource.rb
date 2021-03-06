# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# provides proxy urls for any resource that might need them
module ProxyableResource
  extend ActiveSupport::Concern
  include UrlBuilder

  included do
    # This creates the token used by resource proxy to lookup the attachment.

    has_many :resource_tokens, as: :owner
    delegate :token, to: :resource_token
  end

  # makes a non expiring proxy url
  # version:
  #   is a file version (size) in carrierwave (:detail, :preview, etc)
  # only_path
  #   allows for relative urls
  def non_expiring_proxy_url(version: nil, only_path: true)
    options = { token: resource_token.token,
                version: version,
                only_path: only_path }
    url_for(:resource_proxy, options)
  end

  # a convenience method that can be conditionally proxied or not proxied
  # determined by is_proxied argument
  def proxyable_url(version: nil, is_proxied: false, only_path: true)
    # note: <img src/> must NOT be proxied for pdf, since it gets embeded
    # at create time
    if is_proxied
      non_expiring_proxy_url(version: version, only_path: only_path)
    else
      expiring_s3_url(version)
    end
  end

  def urls_for_resource(resource)
    resource_versions = resource.versions.keys
    default_url = resource.path
    version_urls = Hash[resource_versions.map do |k|
      [k, resource.versions[k].path]
    end]
    { default_url: default_url, version_urls: version_urls }
  end

  def ensure_resource_token_has_urls!(resource)
    return create_resource_token(resource) unless resource_token
    urls = urls_for_resource(resource)

    resource_token.update!(default_url: urls[:default_url])
    resource_token.update!(version_urls: urls[:version_urls])
  end

  def build_resource_token(resource)
    resource_tokens.build urls_for_resource(resource)
  end

  def create_resource_token!(resource)
    build_resource_token(resource).save!
  end

  def destroy_resource_token!
    resource_token.destroy! if resource_token
  end

  # Not memoizing on purpose because it creates a situation where we have an
  # outdated resource token. If you memoize be sure to handle invalidating the
  # cache in every situation where the resource token changes.
  def resource_token
    resource_tokens.order('created_at DESC').first
  end

  private

  def expiring_s3_url(version)
    # unfortunately file.ur(nil) fails, so can't be 'defaulted'
    version ? file.url(version) : file.url
  end
end
