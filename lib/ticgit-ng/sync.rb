module TicGitNG
  module Sync
    def self.external_sync( source, push )
      bugtracker= get_bugtracker(source)
      repo= get_repo(source)
      

      #read bug tracker
      #sort chronologically
      #merge tickets together


    end
  end
  class SyncableTicket
    def read
    end

    def show
    end

    def create
    end

    def update
    end

    def destroy
    end
  end
end
