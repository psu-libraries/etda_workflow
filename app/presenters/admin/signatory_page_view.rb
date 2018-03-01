class Admin::SignatoryPageView
  def initialize(author)
    @author_view = author
  end

  def address_line1
    return '___________________________' if @author_view.address_1.blank? || @author_view.city.blank?
    @author_view.address_1.strip
  end

  def address_line2
    return '____________________________________' if @author_view.city.blank?
    @author_view.city.strip.concat(', ').concat(@author_view.state).concat(' ').concat(@author_view.zip.strip)
  end
end
