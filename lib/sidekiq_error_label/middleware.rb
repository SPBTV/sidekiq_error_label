class SidekiqErrorLabel::Middleware
  module DefaultLabel
  end
  RETRIES_THRESHOLD = 5

  def initialize(options = {})
    @exceptions = options.fetch(:exceptions, [])
    @retries_threshold = options.fetch(:retries_threshold, RETRIES_THRESHOLD)
    @label = options.fetch(:as, DefaultLabel)
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
    job['retry_count'] && job['retry_count'] < @retries_threshold
  end
end
