module Filters
  OPERATOR = [['NOT IN','<','<=','>','>=','NOT BETWEEN'],['IN','>=','>','<=','<','BETWEEN']]

  class FilterWhere
    def self.apply_where(filter, not_filter)
      filter_params = not_filter.present? ? not_filter : filter
      operator      = not_filter.present? ? OPERATOR[0] : OPERATOR[1]

      to_filter = if filter_params.present? && (filter_params.include?('<and>') || filter_params.include?('<or>'))
                    filter_params.split(/<and>|<or>/)
                  elsif filter_params.present?
                    filter_params.partition(' ')
                  end
      filter_attr = []
      filter_attr << (filter_params.include?('==') ? to_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } : nil)
      filter_attr << (filter_params.include?('>=') ? to_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } : nil)
      filter_attr << (filter_params.include?('>>') ? to_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } : nil)
      filter_attr << (filter_params.include?('<=') ? to_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } : nil)
      filter_attr << (filter_params.include?('<<') ? to_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } : nil)

      filter_val = []
      filter_val << (filter_params.include?('==') ? to_filter.map { |p| p.split('==') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } : nil)
      filter_val << (filter_params.include?('>=') ? to_filter.map { |p| p.split('>=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } : nil)
      filter_val << (filter_params.include?('>>') ? to_filter.map { |p| p.split('>>') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } : nil)
      filter_val << (filter_params.include?('<=') ? to_filter.map { |p| p.split('<=') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } : nil)
      filter_val << (filter_params.include?('<<') ? to_filter.map { |p| p.split('<<') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1] } : nil)

      filter_attr_btw = to_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[0] } if filter_params.include?('><')
      filter_val_btw  = to_filter.map { |p| p.split('><') }.delete_if { |p| p.size < 2 }.reject(&:empty?).map { |p| p[1].split('..') } if filter_params.include?('><')

      filter = ''

      5.times do |n|
        if filter_attr[n].present?
          filter_attr[n].each_index do |i|
            filter += ' AND' if i > 0
            filter += " #{filter_attr[n][i]} #{operator[n]} (#{filter_val[n][i]})"
            filter += ' AND' if filter_attr.compact.size > 1
          end
        end
      end

      filter = filter.split(' ')[0...-1].join(' ') if filter.split(' ')[-1] == 'AND'

      filter += ' AND' if filter_attr.compact.size > 0 && filter_attr_btw.present?

      if filter_attr_btw.present?
        filter_attr_btw.each_index do |i|
          filter += ' AND' if i > 0
          filter += " #{filter_attr_btw[i]} #{operator[5]} #{filter_val_btw[i][0]} AND #{filter_val_btw[i][1]}"
        end
      end
      filter
    end
  end
end
