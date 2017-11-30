RSpec.shared_examples "a UniversityDirectory" do
  describe '#autocomplete' do
    it "exists" do
      expect(directory).to respond_to(:autocomplete)
    end
    it "takes one argument" do
      expect(directory.method(:autocomplete).arity).to eq(-2)
    end
  end

  describe '#exists?' do
    it "exists" do
      expect(directory).to respond_to(:exists?)
    end
    it "takes one argument" do
      expect(directory.method(:exists?).arity).to eq(1)
    end
  end

  describe '#retrieve' do
    it "exists" do
      expect(directory).to respond_to(:retrieve)
    end
    it "takes one argument" do
      expect(directory.method(:retrieve).arity).to eq(1)
    end
  end

  describe '#get_psu_id_number' do
    it 'exists' do
      expect(directory.method(:get_psu_id_number).arity).to eq(1)
    end
  end
end
