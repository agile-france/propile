require 'menu'
require 'uri'
require 'htmlentities'

include ActionView::Helpers::TextHelper

module ApplicationHelper
  def errors_for record
    render :partial => 'shared/form_errors', locals: { record: record }
  end

  def title(title)
    content_for(:title) { title }
  end

  def menu(request, &block)
    m = Menu.create(self)
    yield(m) 
    raw m.render(request.parameters, current_account)
  end

  def guarded_link_to(what, url_options)
    return '' unless ActionGuard.authorized?(current_account, url_options.stringify_keys)
    link_to(what, url_options)
  end

  def flash_tags
    raw(flash.collect do |name, message| 
      flash[name] = nil
      self.send("#{name}_flash_tag", message) if message
    end.join)
  end

  private
  def recaptcha_error_flash_tag(message)
    return '' if message != 'recaptcha-not-reachable'
    flash_tag(:recaptcha_error, I18n.t(message))
  end
  def alert_flash_tag(message)
    flash_tag(:alert, message)
  end

  def notice_flash_tag(message)
    flash_tag(:notice, message) + raw(%Q{
      <script type="text/javascript">
        $('#notice').delay(10000).fadeOut('slow');
      </script>
    })
  end

  def flash_tag(name, message)
    content_tag :div, message, :id => "#{name}", :class => "flash"
  end

  def wikinize( text )
    return "" unless text and not text.empty?
    coder = HTMLEntities.new
    text = coder.encode(text, :named).gsub(/[\x0B]/,'')
    if text =~ /^\* /  #list
      text = text.gsub(/^\* (.*)/, '<li>\1</li>')
      text = text.gsub( /<\/li>\n<li>/, '</li><li>' ) #put all bullets in 1 list on same line
      text = text.gsub( /^<li>/, '<ul><li>').gsub( /<\/li>$/, '</li></ul>' )
    end
    text = text.gsub(/(^|[^\[])(#{URI::regexp(['http','https'])})/, '\1<a href="\2">\2</a>') #simple links
    text = text.gsub(/\[\[(#{URI::regexp(['http','https'])}) /, '<a href="\1">[[') #links with name part 1
    text = text.gsub(/\[\[([^\]]*)\]\]/, '\1</a>') #links  with name part 2

    text = text.gsub( /(^|\W)\*([^*\n]*)\*(\W|$)/, '\1<b>\2</b>\3' ) #bold 
    text = text.gsub( /(^|\W)_([^_\n]*)_(\W|$)/, '\1<i>\2</i>\3' )   #italic
     
    simple_format( text )
  end

  def w(text)
    coder = HTMLEntities.new
    coder.encode(text, :named).gsub(/[[:cntrl:]]/,'').html_safe
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def session_presenter_names(session) 
    return "" unless session.presenters && session.presenters[0]
    s = (session.presenters[0] && ( link_to w(session.presenters[0].name), session.presenters[0] )  )
    s += session.presenters[1].nil? ? "" : " & "
    s += (session.presenters[1].nil? ? "" : (link_to w(session.presenters[1].name), session.presenters[1]) )
  end

  def collapse_button(div_id, initially_collapsed=true)
    default_value = (initially_collapsed ? "+" : "-")
    raw(%Q{<input class="collapsebutton" type="button" id="#{div_id}Button" value='#{default_value}' onclick="showHide('#{div_id}')" >})
  end

  def should_hide_presenter(comment)
    !@show_presenter_active
  end

  def collapse_button_initially_open(div_id)
    collapse_button(div_id, false)
  end
end
