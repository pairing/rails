module ActionController
  module Rendering
    extend ActiveSupport::Concern

    included do
      include AbstractController::Rendering
      include AbstractController::LocalizedCache
    end

    def process_action(*)
      self.formats = request.formats.map {|x| x.to_sym}
      super
    end

    def render(*args)
      args << {} unless args.last.is_a?(Hash)
      super(*args)
      self.content_type ||= args.last[:_template].mime_type.to_s
      response_body
    end

    def render_to_body(options)
      _process_options(options)
      super
    end

    private
      def _prefix
        controller_path
      end

      def _determine_template(options)
        if (options.keys & [:partial, :file, :template, :text, :inline]).empty?
          options[:_template_name] ||= options[:action]
          options[:_prefix] = _prefix
        end

        super
      end

      def _render_partial(options)
        options[:partial] = action_name if options[:partial] == true
        options[:_details] = {:formats => formats}
        super
      end

      def format_for_text
        formats.first
      end

      def _process_options(options)
        status, content_type, location = options.values_at(:status, :content_type, :location)
        self.status = status if status
        self.content_type = content_type if content_type
        self.headers["Location"] = url_for(location) if location
      end
  end
end
