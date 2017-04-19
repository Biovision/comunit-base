module EventsHelper
  # @param [Event] entity
  def admin_event_link(entity)
    link_to(entity.name, admin_event_path(entity.id))
  end

  # @param [EventParticipant] entity
  def admin_event_participant_link(entity)
    link_to(entity.full_name, admin_event_participant_path(entity.id))
  end

  # @param [EventProgram] entity
  def admin_event_program_link(entity)
    link_to(entity.name, admin_event_program_path(entity.id))
  end

  # @param [Event] entity
  def event_image_preview(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: entity.name, srcset: versions)
  end

  # @param [Event] entity
  def event_image_medium(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.medium_2x.url} 2x"
    image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSpeaker] entity
  def event_speaker_image_preview(entity)
    return image_tag('biovision/base/placeholders/user.svg') if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSpeaker] entity
  def event_speaker_image_small(entity)
    return image_tag('biovision/base/placeholders/user.svg') if entity.image.blank?

    versions = "#{entity.image.medium.url} 2x"
    image_tag(entity.image.small.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSpeaker] entity
  def event_speaker_image_medium(entity)
    return image_tag('biovision/base/placeholders/user.svg') if entity.image.blank?

    versions = "#{entity.image.medium_2x.url} 2x"
    image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSponsor] entity
  def event_sponsor_image_preview(entity)
    return image_tag('biovision/base/placeholders/image.svg') if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSponsor] entity
  def event_sponsor_image_small(entity)
    return image_tag('biovision/base/placeholders/image.svg') if entity.image.blank?

    versions = "#{entity.image.medium.url} 2x"
    image_tag(entity.image.small.url, alt: entity.name, srcset: versions)
  end

  # @param [EventSponsor] entity
  def event_sponsor_image_medium(entity)
    return image_tag('biovision/base/placeholders/image.svg') if entity.image.blank?

    versions = "#{entity.image.medium_2x.url} 2x"
    image_tag(entity.image.medium.url, alt: entity.name, srcset: versions)
  end
end
