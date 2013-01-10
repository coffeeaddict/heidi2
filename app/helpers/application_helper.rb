module ApplicationHelper
  def js_partial(partial, opts={})
    escape_javascript(render( opts.merge(:partial => partial) ));
  end
end
