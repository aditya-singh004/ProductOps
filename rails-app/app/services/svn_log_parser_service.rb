require "rexml/document"
require "time"

class SvnLogParserService
  TASK_KEY_PATTERN = /\bPO-\d+\b/

  ParsedCommit = Struct.new(:revision, :author, :committed_at, :message, :changed_paths, :task_key, keyword_init: true)

  def initialize(xml)
    @xml = xml
  end

  def parse
    document = REXML::Document.new(@xml)
    commits = []
    REXML::XPath.each(document, "//logentry") do |entry|
      message = text(entry, "msg")
      commits << ParsedCommit.new(
        revision: entry.attributes["revision"],
        author: text(entry, "author"),
        committed_at: Time.parse(text(entry, "date")),
        message: message,
        changed_paths: paths(entry),
        task_key: message.to_s[TASK_KEY_PATTERN]
      )
    end
    commits
  end

  def import!(project)
    parsed = parse
    imported = 0
    duplicates = 0
    linked = 0
    parsed.each do |commit|
      wbs_item = if commit.task_key.present?
                   WbsItem.joins(:requirement).find_by(task_key: commit.task_key, requirements: { project_id: project.id })
                 end
      record = project.svn_commits.find_or_initialize_by(revision: commit.revision)
      if record.persisted?
        duplicates += 1
        next
      end
      record.assign_attributes(commit.to_h.merge(wbs_item: wbs_item, imported_at: Time.current))
      record.save!
      imported += 1
      linked += 1 if wbs_item
    end
    { total: parsed.size, imported: imported, duplicates: duplicates, linked: linked }
  end

  private

  def text(entry, name)
    entry.elements[name]&.text.to_s
  end

  def paths(entry)
    entry.get_elements("paths/path").map do |path|
      { path: path.text, action: path.attributes["action"], kind: path.attributes["kind"] }
    end
  end
end
