module Filters::FilterWhere
  def self.apply_where(filter_params)
    to_filter = if (filter_params.present? && (filter_params.include?('<and>') || filter_params.include?('<or>')))
                  filter_params.split(/<and>|<or>/)
                else
                  filter_params.partition(' ') if filter_params.present?
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

    # ToDo "WHERE ... OR ..."
    filter = ""

    if filter_attr_1.present?
      filter_attr_1.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_1[i]} IN (#{filter_val_1[i]})"
      end
    end

    filter += " AND" if (filter_attr_1.present? && filter_attr_2.present?)

    if filter_attr_2.present?
      filter_attr_2.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_2[i]} >= #{filter_val_2[i]}"
      end
    end

    filter += " AND" if ((filter_attr_1.present? || filter_attr_2.present?) && filter_attr_3.present?)

    if filter_attr_3.present?
      filter_attr_3.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_3[i]} > #{filter_val_3[i]}"
      end
    end

    filter += " AND" if ((filter_attr_1.present? || filter_attr_2.present? || filter_attr_3.present?) && filter_attr_4.present?)

    if filter_attr_4.present?
      filter_attr_4.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_4[i]} <= #{filter_val_4[i]}"
      end
    end

    filter += " AND" if ((filter_attr_1.present? || filter_attr_2.present? || filter_attr_3.present? || filter_attr_4.present?) && filter_attr_5.present?)

    if filter_attr_5.present?
      filter_attr_5.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_5[i]} < #{filter_val_5[i]}"
      end
    end

    filter += " AND" if ((filter_attr_1.present? || filter_attr_2.present? || filter_attr_3.present? || filter_attr_4.present? || filter_attr_5.present?) && filter_attr_6.present?)

    if filter_attr_6.present?
      filter_attr_6.each_index do |i|
        filter += " AND" if i > 0
        filter += " #{filter_attr_6[i]} BETWEEN #{filter_val_6[i][0]} AND #{filter_val_6[i][1]}"
      end
    end

    filter
  end
end