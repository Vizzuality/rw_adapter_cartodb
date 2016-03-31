class QueryParams < Hash
  def initialize(params)
    sanitized_params = {
      select: params['select'].present? ? params['select'] : [],
      order:  params['order'].present?  ? params['order']  : [],
      filter: filter_params(params['filter']) || nil,
      not_filter: filter_params(params['filter_not']) || nil
    }

    super(sanitized_params)
    self.merge!(sanitized_params)
  end

  def self.sanitize(params)
    new(params)
  end

  private

    def filter_params(filter)
      if (filter.present? && validate_params(filter))
        filter = filter.delete! '()'
        filter.gsub('"', "'")
      end
    end

    def validate_params(filter)
      filter.include?('==') || filter.include?('>=') || filter.include?('>>') || filter.include?('<=') || filter.include?('<<') || filter.include?('..') || filter.include?('><')
    end
end
