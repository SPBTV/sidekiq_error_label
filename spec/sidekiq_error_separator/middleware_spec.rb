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

  context '#call' do
    subject(:silencer) do
      SidekiqErrorSeparator::Middleware.new exceptions: [exception]
    end

    it 'raise silented exception :retries_threshold times' do
      SidekiqErrorSeparator::Middleware::RETRIES_THRESHOLD.times do |try|
        expect(silencer).to receive(:retry_number).and_return(try)
        expect {
          silencer.call(worker, job, 'default') do
            raise exception
          end
        }.to raise_error(SidekiqErrorSeparator::Middleware::ImportantException)
      end
    end

    it 'raise not silented exception on :retries_threshold + 1 times' do
      try = SidekiqErrorSeparator::Middleware::RETRIES_THRESHOLD + 1
      expect(silencer).to receive(:retry_number).and_return(try)

      begin
        silencer.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).not_to be_kind_of SidekiqErrorSeparator::Middleware::ImportantException
        expect(error).to be_kind_of exception
      end
    end
  end

  context ':retries_threshold parameter' do
    let(:retries_threshold) { 1 }

    subject(:silencer) do
      SidekiqErrorSeparator::Middleware.new exceptions: [exception], retries_threshold: retries_threshold
    end

    it 'overwrites default value' do
      expect(silencer).to receive(:retry_number).and_return(retries_threshold)

      begin
        silencer.call(worker, job, 'default') do
          raise exception
        end
      rescue => error
        expect(error).not_to be_kind_of SidekiqErrorSeparator::Middleware::ImportantException
        expect(error).to be_kind_of exception
      end
    end
  end
end
