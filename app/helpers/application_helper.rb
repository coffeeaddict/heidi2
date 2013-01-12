module ApplicationHelper
  def js_partial(partial, opts={})
    escape_javascript(render( opts.merge(:partial => partial) ));
  end

  def md(content)
    emojify GitHub::Markdown.render_gfm(content).html_safe
  end

  def emojify(content)
    h(content).to_str.gsub(/:([a-z0-9\+\-_]+):/) do |match|
      if Emoji.names.include?($1)
        '<img alt="' + $1 + '" height="20" src="' + asset_path("emoji/#{$1}.png") + '" style="vertical-align:middle" width="20" />'
      else
        match
      end
    end.html_safe if content.present?
  end

  def ansi_color_codes(string)
    return "" if string.nil?

    string.gsub(/\e\[0?m/, '</span>').
      gsub /\e\[[^m]+m/ do |codes|
        colors = codes.gsub(/[\e\[m]+/, '')
        classes = colors.split(";").collect { |c| "color#{c}" }
        "<span class=\"#{classes.join(" ")}\">"
      end.html_safe
  end
end
