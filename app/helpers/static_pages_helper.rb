module StaticPagesHelper
  def cache_key_for_instructions
	"instructions-#{Time.now.to_i}"
  end

end


