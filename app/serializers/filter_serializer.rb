module FilterSerializer
  module_function

  def call(definition)
    { key: definition.key, name: definition.name, kind: definition.kind, required: definition.required,
      options: definition.filter_options.map { |o| { value: o.value, label: o.label, featured: o.featured } } }
  end
end
