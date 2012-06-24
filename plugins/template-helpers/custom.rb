class Ruhoh
  module Templaters
    module Helpers
      def docroot
        docroot = self.context['site']['config']['env'] == 'production' ? self.context['site']['config']['production_url'] : Ruhoh::DB.site['config']['dev_url']
        docroot ||= '/'
        docroot
      end
    end
  end
end
