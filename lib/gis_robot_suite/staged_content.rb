# frozen_string_literal: true

module GisRobotSuite
  # Locates a druid's staged content in the assembly root or the GIS staging root.
  # Adapted from Dor::StagedContent in common-accessioning.
  class StagedContent
    class MultipleRootsError < StandardError; end
    class NotFoundError < StandardError; end

    # @param druid [String]
    # @return [StagedContent, nil] nil when no root has the druid
    # @raise [MultipleRootsError] when more than one root has the druid
    def self.find(druid)
      found = roots.filter_map do |root, base|
        druid_tools = DruidTools::Druid.new(druid, base)
        new(root:, druid_tools:) if druid_tools.pathname.exist?
      end
      raise MultipleRootsError, "Staged content found in multiple roots: #{found.map(&:pathname).join(', ')}" if found.size > 1

      found.first
    end

    # @param druid [String]
    # @return [StagedContent]
    # @raise [NotFoundError] when no root has the druid
    # @raise [MultipleRootsError] when more than one root has the druid
    def self.find!(druid)
      find(druid) || raise(NotFoundError, "No staged content for #{druid} in #{roots.values.join(' or ')}")
    end

    def self.roots
      { assembly: Settings.geohydra.assembly, staging: Settings.geohydra.stage }
    end
    private_class_method :roots

    # @return [Symbol] :assembly or :staging
    attr_reader :root

    def initialize(root:, druid_tools:)
      @root = root
      @druid_tools = druid_tools
    end

    # @return [Pathname] the druid's directory in the root
    def pathname
      druid_tools.pathname
    end

    def assembly?
      root == :assembly
    end

    def staging?
      root == :staging
    end

    private

    attr_reader :druid_tools
  end
end
