require 'sidekiq/worker'

RSpec.describe SidekiqErrorLabel::Middleware do
  let(:worker) do
    Class.new  do
      include ::Sidekiq::Worker
    end
  end
  let(:my_label) { Module.new }
  let(:exception) { Class.new(StandardError) }

  let(:job) do
    { 'class' => 'Bob', 'args' => [1,2,'foo'], 'retry' => 2, 'jid' => 'jid-string' }
  end

  context '#label?' do
    let(:retries_threshold) { SidekiqErrorLabel::Middleware::RETRIES_THRESHOLD }
    subject do
      SidekiqErrorLabel::Middleware.new exceptions: [exception]
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
      separator = SidekiqErrorLabel::Middleware.new exceptions: [exception], retries_threshold: 1
      the_job = job.dup.merge('retry_count' => 1)
      expect(separator.label_exception?(the_job)).to be_falsey
    end
  end

  context '#call' do
    subject do
      SidekiqErrorLabel::Middleware.new exceptions: [exception]
    end

    it 'raise not labeled exception' do
      expect(subject).to receive(:label_exception?).with(job).and_return(false)
      begin
        subject.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).not_to be_kind_of SidekiqErrorLabel::Middleware.label
        expect(error).to be_kind_of exception
      end
    end

    it 'raise labeled exception' do
      expect(subject).to receive(:label_exception?).with(job).and_return(true)
      begin
        subject.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).to be_kind_of SidekiqErrorLabel::Middleware.label
        expect(error).to be_kind_of exception
      end
    end

    it 'count :as option' do
      separator = SidekiqErrorLabel::Middleware.new exceptions: [exception], as: my_label
      expect(separator).to receive(:label_exception?).with(job).and_return(true)
      begin
        separator.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).not_to be_kind_of SidekiqErrorLabel::Middleware.label
        expect(error).to be_kind_of my_label
        expect(error).to be_kind_of exception
      end
    end
  end

  context '.label' do
    it 'create new label' do
      label = SidekiqErrorLabel::Middleware.label(:default)
      expect(label).to eq SidekiqErrorLabel::Middleware::Labels::Default
    end

    it 'return same label if called twice' do
      label = SidekiqErrorLabel::Middleware.label(:default)

      expect(SidekiqErrorLabel::Middleware.label(:default)).to eq label
    end
  end
end
