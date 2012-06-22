class Ruhoh
        module Templaters
                module Helpers
                        def docroot
                                docroot =
                                        self.context['site']['config']['environment']
                                == 'production' ?
                                        self.context['site']['config']['production_url']
                                : self.context['site']['config']['dev_url']
                                docroot
                        end
                end
        end
end
