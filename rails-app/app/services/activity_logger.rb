class ActivityLogger
  def self.log(user:, project: nil, entity:, action:, metadata: {})
    ActivityLog.create!(
      user: user,
      project: project || entity.try(:project),
      entity_type: entity.class.name,
      entity_id: entity.id,
      action: action,
      metadata: metadata
    )
  end
end
