-- luacheck: globals handleOnNewScan driver

local scanCounter = 0

--Start of Global Scope---------------------------------------------------------
local scanFilePath = 'resources/TestScenario.xml'

-- Check device capabilities
assert(View, 'View not available, check capability of connected device')
assert(Scan, 'Scan not available, check capability of connected device')
assert(Scan.MovingAveragingFilter, 'MovingAveragingFilter not available, check capability of connected device')

-- Create a viewer instance
local viewer = View.create()
assert(viewer, 'View could not be created.')

local scanDeco = View.ScanDecoration.create()
assert(scanDeco, 'ScanDecoration could not be created')
View.ScanDecoration.setPointSize(scanDeco, 5)

-- Create the required filter
local movingAverageFilter = Scan.MovingAveragingFilter.create()
assert(movingAverageFilter, 'MovingAveragingFilter could not be created')
-- Set filter parameters
Scan.MovingAveragingFilter.setAverageDepth(movingAverageFilter, 3)
Scan.MovingAveragingFilter.setEnabled(movingAverageFilter, true)

-- Create driver and start playing
-- luacheck: globals driver
driver = Scan.Provider.File.create()
assert(driver, 'ScanFile driver could not be created.')

-- Set the path
Scan.Provider.File.setFile(driver, scanFilePath)
-- reduce data rate to 10 scans per seconds to avoid overruns for slow devices
Scan.Provider.File.setDelayMs(driver, 100)
-- Register callback, driver starts providing automatically like other real scan device drivers
Scan.Provider.File.register(driver, 'OnNewScan', 'handleOnNewScan')

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Calculate the average distance differences which are not larger than the
-- given threshold, processes the first echo only!
-------------------------------------------------------------------------------------------------------
local function getAverageDelta(inputScan, filteredScan, threshold, printDetails)
  -- Get the beam and echo counts
  local beamCountInput = Scan.getBeamCount(inputScan)
  local beamCountFiltered = Scan.getBeamCount(filteredScan)

  local count = 0
  local sum = 0.0

  -- Checks
  if (beamCountInput == beamCountFiltered) then
    -- Print beams with different distances
    if (printDetails) then
      print('The following beams have different distance values:')
    end
    for iBeam = 1, beamCountInput do
      local d1 = Scan.getPointDistance(inputScan, iBeam - 1, 0)
      local d2 = Scan.getPointDistance(filteredScan, iBeam - 1, 0)
      local delta = math.abs(d1 - d2)
      -- if the delta is too big it is NOT a statistical variation
      if (delta < threshold) then
        if (printDetails) then
          print(string.format('  %d:  %10.2f <-> %10.2f', iBeam, d1, d2))
        end
        count = count + 1
        sum = sum + delta
      end
    end
    local average = 0.0
    if (count > 0) then
      average = sum / count
    end
    return count, sum, average
  end
end

-- Callback function to process new scans
function handleOnNewScan(scan)
  scanCounter = scanCounter + 1
  -- Clone input scan
  local inputScan = Scan.clone(scan)

  -- Call movingAverageFilter filter
  local filteredScan = Scan.MovingAveragingFilter.filter(movingAverageFilter, scan)
  if (filteredScan ~= nil) then
    -- Analyze filtered scan: get estimation of noise level
    -- larger differences are considered as real and are ignored
    local threshold = 20.0
    local _,  _, average = getAverageDelta(inputScan, filteredScan, threshold, false)
    print(
      string.format(
        'scan %d: average difference between movingAverageFilter distance and distance of last scan = %10.2f',
        scanCounter,
        average
      )
    )
    View.clear(viewer)
    View.addScan(viewer, scan, scanDeco)
    View.present(viewer)
  end
end

--End of Function and Event Scope------------------------------------------------
