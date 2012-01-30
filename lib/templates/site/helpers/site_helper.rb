module SiteHelper
  
  def page_id(txt = nil)
    content_for(:__pageid, txt) if txt
    return content_for(:__pageid) unless txt
    ""
  end
  
  def page_title(txt = nil)
    content_for(:__title, txt) if txt
    return content_for(:__title) unless txt
    ""
  end
  
  def keywords    
  end
  
end