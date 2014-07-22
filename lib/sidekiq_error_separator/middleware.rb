class SidekiqErrorSeparator::Middleware
  module DefaultLabel
  end
  RETRIES_THRESHOLD = 5

  def initialize(options = {})
    @exceptions = options.fetch(:exceptions) do
      []
    end

    @retries_threshold = options.fetch(:retries_threshold, RETRIES_THRESHOLD)
  end

  def call(worker, job, queue)
    yield
  rescue *@exceptions => error
    if label_exception?(job)
      error.extend DefaultLabel
      raise error
    else
      raise
    end
  end

  def label_exception?(job)
    job['retry_count'] && job['retry_count'] < @retries_threshold
  end
end
