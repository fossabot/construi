
module Construi
  class Target
    attr_reader :name, :config

    def initialize(name, config)
      @name = name
      @config = config
    end

    def commands
      @config.commands
    end

    def run
      puts "Running #{name}...".green

      links = start_linked_images

      begin
        final_image = IntermediateImage.seed(create_initial_image).reduce(commands) do |image, command|
          puts
          puts " > #{command}".green
          image.run command, @config.options
        end

        final_image.delete
      ensure
        links.map(&:delete)
      end
    end

    def create_initial_image
      return Image.from(@config)
    end

    def start_linked_images
      @config.links.map do |(name, config)|
        Image.from(config).start(config.options.merge name: name, log_lifecycle: true)
      end
    end
  end

end

