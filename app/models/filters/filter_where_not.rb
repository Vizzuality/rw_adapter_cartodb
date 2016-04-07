module Filters
  class FilterWhereNot
    def self.apply_where_not(filter_params)
      not_filter = if filter_params.present? && (filter_params.include?('<and>') || filter_params.include?('<or>'))
                     filter_params.split(/<and>|<or>/)
                   elsif filter_params.present?
                     filter_params.partition(' ')
                   end

      filter_attr_not_1 = not_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('==')
      filter_val_not_1  = not_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('==')
      filter_attr_not_2 = not_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('>=')
      filter_val_not_2  = not_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('>=')
      filter_attr_not_3 = not_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('>>')
      filter_val_not_3  = not_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('>>')
      filter_attr_not_4 = not_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('<=')
      filter_val_not_4  = not_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('<=')
      filter_attr_not_5 = not_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('<<')
      filter_val_not_5  = not_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } if filter_params.include?('<<')

      filter_attr_not_6 = not_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('><')
      filter_val_not_6  = not_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1].split('..') } if filter_params.include?('><')

      # TODO: "WHERE ... OR ..."
      filter = ''

      if filter_attr_not_1.present?
        filter_attr_not_1.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_1[i]} NOT IN (#{filter_val_not_1[i]})"
        end
      end

      filter += ' AND' if filter_attr_not_1.present? && filter_attr_not_2.present?

      if filter_attr_not_2.present?
        filter_attr_not_2.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_2[i]} < #{filter_val_not_2[i]}"
        end
      end

      filter += ' AND' if (filter_attr_not_1.present? || filter_attr_not_2.present?) && filter_attr_not_3.present?

      if filter_attr_not_3.present?
        filter_attr_not_3.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_3[i]} <= #{filter_val_not_3[i]}"
        end
      end

      filter += ' AND' if (filter_attr_not_1.present? || filter_attr_not_2.present? || filter_attr_not_3.present?) && filter_attr_not_4.present?

      if filter_attr_not_4.present?
        filter_attr_not_4.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_4[i]} > #{filter_val_not_4[i]}"
        end
      end

      filter += ' AND' if (filter_attr_not_1.present? || filter_attr_not_2.present? || filter_attr_not_3.present? || filter_attr_not_4.present?) && filter_attr_not_5.present?

      if filter_attr_not_5.present?
        filter_attr_not_5.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_5[i]} >= #{filter_val_not_5[i]}"
        end
      end

      filter += ' AND' if (filter_attr_not_1.present? || filter_attr_not_2.present? || filter_attr_not_3.present? || filter_attr_not_4.present? || filter_attr_not_5.present?) && filter_attr_not_6.present?

      if filter_attr_not_6.present?
        filter_attr_not_6.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_not_6[i]} NOT BETWEEN #{filter_val_not_6[i][0]} AND #{filter_val_not_6[i][1]}"
        end
      end

      filter
    end
  end
end
