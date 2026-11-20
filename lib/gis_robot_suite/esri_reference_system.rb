# frozen_string_literal: true

module GisRobotSuite
  # The coordinate reference system the ArcGIS metadata names, for data that declares none of its
  # own: shapefiles accessioned without a .prj, and rasters whose CRS PROJ can't use.
  #
  # This is the same reference system generate-descriptive records as the cocina map projection,
  # since ArcGIS2ISO19139.xsl copies it into the ISO 19139 the builder reads. Reading it here
  # instead means the bounding box can be computed before the ISO 19139 exists.
  module EsriReferenceSystem
    # A record may name several: the one authored in the original record and the one ArcGIS synced
    # from the data, which ArcGIS marks Sync="TRUE". Prefer the synced one, as
    # DescriptiveMetadataBuilder#reference_system_node does, since it describes the data rather
    # than what the record claims about it.
    #
    # @param esri_ng [Nokogiri::XML::Document]
    # @return [String, nil] the CRS as AUTHORITY:CODE, e.g. "EPSG:32652", or nil when none is named
    def self.crs(esri_ng)
      identifiers = esri_ng.xpath('//refSysInfo/RefSystem/refSysID').filter_map { |ref_sys_id| identifier(ref_sys_id) }

      (identifiers.find { |_crs, synced| synced } || identifiers.first)&.first
    end

    # The code is in identCode's code attribute, or failing that its text, as ArcGIS2ISO19139.xsl
    # reads it.
    def self.identifier(ref_sys_id)
      ident_code = ref_sys_id.at_xpath('identCode')
      return unless ident_code

      code = ident_code['code'].presence || ident_code.text.strip
      authority = ref_sys_id.at_xpath('idCodeSpace')&.text&.strip
      return if code.blank? || authority.blank?

      ["#{authority}:#{code}", ident_code['Sync'] == 'TRUE']
    end
    private_class_method :identifier
  end
end
