require "benchmark"
require "async"
require "parallel"

# Генерация файлов для примера
files = 5.times.map do |i|
  filename = "file_#{i}.txt"
  File.open(filename, 'w') { |f| f.puts(Array.new(100_000) { "Line from #{filename}" }) }
  filename
end

# puts Sequentially
def process_files_sequentially(files)
  files.each do |file|
    File.open(file, 'r') do |f|
      f.each_line { |line| puts line }
    end
  end
end

# puts in parallel
def process_files_in_parallel(files)
  Parallel.each(files) do |file|
    File.open(file, 'r') do |f|
      f.each_line { |line| puts line }
    end
  end
end


Benchmark.bm do |x|
  x.report('sequential:') do
    process_files_sequentially(files)
  end

  x.report('parallel:') do
    process_files_in_parallel(files)
  end
end

# user     system      total        real
# sequential:   1.036363   1.317511   2.353874 (  2.416077)
# concurrency:  0.001577   0.011565   9.841909 (  2.558235)
# Если не применять оптимизации - буферизацию, чтение файла целиком и тд, то
# Единственное адекватное решение - через форк процессов (по умолчанию в parallel)
# По CPU и IO - (user и system) видно, что прирост есть, но по факту - нет 
# скорее всего из-за bottleneck при синхронизации ОС доступа к терминалу
# Пробовал Thread (в несколько раз медленнее чем seq из-за переключения контекста)
# Пробовал Async - +- также как и у seq.
# Пробовал Ractor - +- также как и у seq.