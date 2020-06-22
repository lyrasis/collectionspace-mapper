# frozen_string_literal: true

RSpec.describe CollectionSpace::Mapper::DataMapper do
  let(:anthro_co_1) {
    {"objectNumber"=>"20CS.001.0001",
                 "objectProductionPeopleEthnoculture"=>"Batak; ",
                 "objectProductionPeopleArchculture"=>"; Blackfoot",
                 "objectProductionPeopleRole"=>"traditional makers; designed after",
                 "productionNote"=>"Production note text.",
                 "fieldLocPlace"=>"York County, Pennsylvania",
                 "fieldLocCounty"=>"York",
                 "fieldLocState"=>"PA",
                 "localityNote"=>"Sample locality note 1",
                 "nagpraCategory"=>"subject to NAGPRA (unspec.);not subject to NAGPRA",
                 "nagpraReportFiled"=>"Y",
                 "nagpraReportFiledBy"=>"Ann Analyst",
                 "nagpraReportFiledDate"=>"1/2/2019",
                 "repatriationNote"=>"Repatriation note 1; Repatriation note 2",
                 "minIndividuals"=>"1;2",
                 "ageRange"=>"Adolescent 26 - 75%;Adult 0 - 25%",
                 "side"=>";midline",
                 "dentition"=>";true",
                 "bone"=>";fdgg",
                 "commingledRemainsSex"=>";Possibly female",
                 "count"=>";2",
                 "mortuaryTreatment"=>
                   "burned/unburned bone mixture^^enbalmed;excarnated^^mummified",
                 "mortuaryTreatmentNote"=>"mtnote1^^mtnote2;mtnote3^^mtnote4",
                 "behrensmeyerSingleLower"=>"1; 3",
                 "behrensmeyerUpper"=>"2; 5",
                 "commingledRemainsNote"=>"crnote2;crnote2",
                 "annotationNote"=>"Stored in coffee can; Photographed by staff",
                 "annotationType"=>"type; image made",
                 "annotationDate"=>"12/19/2019;12/10/2019",
                 "annotationAuthor"=>"Ann Analyst; Gabriel Solares",
                 "culturalCareNote"=>nil,
                 "limitationDetails"=>nil,
                 "limitationLevel"=>nil,
                 "limitationType"=>nil,
                 "requestDate"=>nil,
                 "requester"=>nil,
                 "requestOnBehalfOf"=>nil,
                 "dataHashID"=>2
    }
  }
  let(:rm_anthro_co) { RecordMapperUntangler.new(profile: 'anthro_4_0_0', rectype: 'collectionobject').to_h }
  let(:dm) { DataMapper.new(record_mapper: rm_anthro_co, data: anthro_co_1) }

  it 'returns DataMapper object' do
    expect(dm).to be_a(CollectionSpace::Mapper::DataMapper)
  end

  describe '#doc' do
    it 'returns XML document' do
      expect(dm.doc).to be_a(Nokogiri::XML::Document)
    end
  end
end
