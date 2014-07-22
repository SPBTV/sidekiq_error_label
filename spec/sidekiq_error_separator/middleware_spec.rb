require 'sidekiq/worker'

RSpec.describe SidekiqErrorSeparator::Middleware do
  let(:worker) do
    Class.new  do
      include ::Sidekiq::Worker
    end
  end
  let(:exception) { Class.new(StandardError) }
  let(:job) do
    { 'class' => 'Bob', 'args' => [1,2,'foo'], 'retry' => 2, 'jid' => 'jid-string' }
  end

  context '#label?' do
    let(:retries_threshold) { SidekiqErrorSeparator::Middleware::RETRIES_THRESHOLD }
    subject do
      SidekiqErrorSeparator::Middleware.new exceptions: [exception]
    end

    it 'should not #label_exception? if retry_count is not set' do
      expect(subject.label_exception?(job.dup)).to be_falsey
    end

    it '#label_exception? if retry_count is less then retries_threshold' do
      the_job = job.dup.merge('retry_count' => retries_threshold - 1)
      expect(subject.label_exception?(the_job)).to be_truthy
    end

    it 'should not #label_exception? if retry_count is equals to retries_threshold' do
      the_job = job.dup.merge('retry_count' => retries_threshold)
      expect(subject.label_exception?(the_job)).to be_falsey
    end

    it 'should not #label_exception? if retry_count is greater then retries_threshold' do
      the_job = job.dup.merge('retry_count' => retries_threshold + 1)
      expect(subject.label_exception?(the_job)).to be_falsey
    end

    it 'should count :retries_threshold options' do
      separator = SidekiqErrorSeparator::Middleware.new exceptions: [exception], retries_threshold: 1
      the_job = job.dup.merge('retry_count' => 1)
      expect(separator.label_exception?(the_job)).to be_falsey
    end
  end

  context '#call' do
    subject do
      SidekiqErrorSeparator::Middleware.new exceptions: [exception]
    end

    it 'raise not labeled exception' do
      expect(subject).to receive(:label_exception?).and_return(false)
      begin
        subject.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).not_to be_kind_of SidekiqErrorSeparator::Middleware::DefaultLabel
        expect(error).to be_kind_of exception
      end
    end

    it 'raise labeled exception' do
      expect(subject).to receive(:label_exception?).and_return(true)
      begin
        subject.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).to be_kind_of SidekiqErrorSeparator::Middleware::DefaultLabel
        expect(error).to be_kind_of exception
      end
    end
  end
end
