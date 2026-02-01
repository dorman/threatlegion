class MakeThreatIdOptionalForIndicatorsAndVulnerabilities < ActiveRecord::Migration[7.2]
  def change
    change_column_null :indicators, :threat_id, true
    change_column_null :vulnerabilities, :threat_id, true
  end
end
