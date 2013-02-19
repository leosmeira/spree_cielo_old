ApplicationHelper.module_eval do
  def if_property(object, property, &block)
    property = object.send(property)
    block.call(property) unless property.nil?
    return
  end
end