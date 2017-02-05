class Canonizer
  MAP = {
      'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'g', 'д' => 'd', 'е' => 'e', 'ё' => 'yo', 'ж' => 'zh',
      'з' => 'z', 'и' => 'i', 'й' => 'j', 'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n', 'о' => 'o',
      'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't', 'у' => 'u', 'ф' => 'f', 'х' => 'kh', 'ц' => 'c',
      'ч' => 'ch', 'ш' => 'sh', 'щ' => 'shh', 'ъ' => '', 'ы' => 'y', 'ь' => '', 'э' => 'e', 'ю' => 'yu',
      'я' => 'ya',
  }

  def self.transliterate(text)
    result = text.mb_chars.downcase.to_s
    MAP.each { |r, e| result.gsub!(r, e) }
    result.downcase.gsub(/[^-a-z0-9_]/, '-').gsub(/^[-_]*([-a-z0-9_]*[a-z0-9]+)[-_]*$/, '\1').gsub(/--+/, '-')
  end

  def self.canonize(input)
    lowered   = input.mb_chars.downcase.to_s.strip
    canonized = lowered.gsub(/[^a-zа-я0-9ё]/, '')
    canonized.empty? ? lowered : canonized
  end

  def self.urlize(input)
    lowered = input.mb_chars.downcase.to_s.squish
    lowered.gsub(/[^a-zа-я0-9ё]/, '-').gsub(/-\z/, '')
  end
end
