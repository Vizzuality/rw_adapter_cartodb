class QueryParams < Hash
  def initialize(params)
    sanitized_params = {
      select: params['select'].present? ? params['select'] : [],
      order: params['order'].present? ? params['order'] : []
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end
end
