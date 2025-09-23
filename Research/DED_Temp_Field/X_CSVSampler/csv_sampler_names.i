[StochasticTools]
[]

[Samplers]
  [sample]
    type = CSVSampler
    samples_file = 'data_points.csv'
    # column_names = 'a b'
    execute_on = 'initial timestep_end'
  []
[]

[VectorPostprocessors]
  [data]
    type = SamplerData
    sampler = sample
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  execute_on = 'INITIAL TIMESTEP_END'
  csv = true
  file_base = CSV_Sampler_name_test_2
[]
