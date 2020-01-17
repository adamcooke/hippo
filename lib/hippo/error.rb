# frozen_string_literal: true

module Hippo
  class Error < StandardError
  end

  class RepositoryAlreadyClonedError < Error
  end

  class RepositoryCloneError < Error
  end

  class RepositoryFetchError < Error
  end

  class RepositoryCheckoutError < Error
  end
end
