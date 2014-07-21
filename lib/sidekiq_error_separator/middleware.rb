class SidekiqErrorSeparator::Middleware
  module ImportantException
  end
  RETRIES_THRESHOLD = 5

  def initialize(options = {})
    @exceptions = options.fetch(:exceptions) do
      []
    end

    @retries_threshold = options.fetch(:retries_threshold, RETRIES_THRESHOLD)
  end

  def call(worker, item, queue)
    yield
  rescue *@exceptions => error
    if retry_number(item) < @retries_threshold
      error.extend ImportantException
      raise error
    else
      raise
    end
  end

  private
  def null_retry_set_entry
    lambda do
      {
        'retry_count' => 0
      }
    end
  end

  def retry_number(item)
    Sidekiq::RetrySet.new.detect(null_retry_set_entry) { |job| job.jid == item['jid'] }['retry_count']
  end
end
