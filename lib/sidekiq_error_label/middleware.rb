require 'active_support/inflections'

class SidekiqErrorLabel::Middleware
  require_relative 'labels'

  RETRIES_THRESHOLD = 5

  def initialize(options = {})
    @exceptions = options.fetch(:exceptions, [])
    @retries_threshold = options.fetch(:retries_threshold, RETRIES_THRESHOLD)
    @label = options.fetch(:as, self.class.label)
  end

  def call(worker, job, queue)
    yield
  rescue *@exceptions => error
    if label_exception?(job)
      error.extend @label
      raise error
    else
      raise
    end
  end

  def label_exception?(job)
    job['retry_count'].nil? || job['retry_count'] < @retries_threshold
  end

  def self.label(name = :default)
    label_name = name.to_s.classify.to_sym
    if Labels.constants.include?(label_name)
      Labels.const_get(label_name)
    else
      Labels.const_set(label_name, Module.new)
    end
  end
end
