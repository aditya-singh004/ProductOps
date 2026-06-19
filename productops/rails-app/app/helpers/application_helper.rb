module ApplicationHelper
  def badge(value)
    tag.span(value.to_s.titleize, class: "badge badge-#{value.to_s.parameterize}")
  end

  def percent_bar(value)
    tag.div(class: "progress") do
      tag.div("", class: "progress-fill", style: "width: #{value.to_i.clamp(0, 100)}%")
    end
  end
end
