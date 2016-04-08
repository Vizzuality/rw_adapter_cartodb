module Filters
  class FilterWhere
    def self.apply_where(filter, not_filter)
      filter_params = not_filter.present? ? not_filter : filter

      to_filter = if filter_params.present? && (filter_params.include?('<and>') || filter_params.include?('<or>'))
                    filter_params.split(/<and>|<or>/)
                  elsif filter_params.present?
                    filter_params.partition(' ')
                  end

      filter_attr_1 = to_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('==')
      filter_val_1  = to_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('==')
      filter_attr_2 = to_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('>=')
      filter_val_2  = to_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('>=')
      filter_attr_3 = to_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('>>')
      filter_val_3  = to_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('>>')
      filter_attr_4 = to_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('<=')
      filter_val_4  = to_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('<=')
      filter_attr_5 = to_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('<<')
      filter_val_5  = to_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('<<')

      filter_attr_6 = to_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('><')
      filter_val_6  = to_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1].split('..') } if filter_params.include?('><')

      filter_attr = []
      1.upto(5) do |n|
        filter_attr << eval('filter_attr_'+"#{n}")
      end

      # TODO: "WHERE ... OR ..."
      filter = ''

      1.upto(5) do |n|
        operator_1 = not_filter.present? ? 'NOT IN' : 'IN'
        operator_2 = not_filter.present? ? '<' : '>='
        operator_3 = not_filter.present? ? '<=' : '>'
        operator_4 = not_filter.present? ? '>' : '<='
        operator_5 = not_filter.present? ? '>=' : '<'
        if eval('filter_attr_'+"#{n}").present?
          eval('filter_attr_'+"#{n}").each_index do |i|
            filter += ' AND' if i > 0
            filter += " #{eval('filter_attr_'+"#{n}")[i]} #{eval('operator_'+"#{n}")} (#{eval('filter_val_'+"#{n}")[i]})"
            filter += ' AND' if filter_attr.compact.size > 1
          end
        end
      end

      filter = filter.split(' ')[0...-1].join(' ') if filter.split(' ')[-1] == 'AND'

      filter += ' AND' if filter_attr.compact.size > 0 && filter_attr_6.present?

      if filter_attr_6.present?
        operator = not_filter.present? ? 'NOT BETWEEN' : 'BETWEEN'
        filter_attr_6.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_6[i]} #{operator} #{filter_val_6[i][0]} AND #{filter_val_6[i][1]}"
        end
      end
      filter
    end
  end
end
