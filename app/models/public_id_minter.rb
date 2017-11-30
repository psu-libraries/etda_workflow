class PublicIdMinter
  def initialize(submission)
    @public_id_minter = ''
    @id_segment = [submission.id.to_s, access_id_info(submission.author), author_id_info(submission.author)]
    return nil if @id_segment.length < 2
  end

  def id
    @public_id_minter = unique_id
  end

  private

    def unique_id
      tmp_id = @id_segment[0]
      pos = 1
      while pos < @id_segment.length
        tmp_id += @id_segment[pos]
        return tmp_id if Submission.find_by(public_id: tmp_id).nil?
        pos += 1
      end
      ''
    end

    def access_id_info(author)
      return nil if author.nil?
      return "-#{author.id}" if author.access_id.empty?
      author.access_id
    end

    def author_id_info(author)
      return nil if author.nil?
      str = "-#{author.id}"
      return '' if str == '-'
      str
    end
end
