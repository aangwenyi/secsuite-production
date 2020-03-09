--
-- Database: `status`
--

-- --------------------------------------------------------

--
-- Table structure for table `apachestatus`
--

CREATE TABLE `apachestatus` (
  `id` int(11) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  `apachestatus` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `hist_apachestatus`
--

CREATE TABLE `hist_apachestatus` (
  `id` int(11) NOT NULL,
  `hostname` varchar(255) NOT NULL,
  `apachestatus` varchar(1000) NOT NULL,
  `importtime` varchar(255) NOT NULL,
  ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `cpu`
--

CREATE TABLE `cpu` (
  `id` int(11) NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `loadonemin` varchar(10) DEFAULT NULL,
  `loadtenmin` varchar(10) DEFAULT NULL,
  `loadfifmin` varchar(10) DEFAULT NULL,
  `x` varchar(10) NOT NULL,
  `y` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `hist_cpu`
--

CREATE TABLE `hist_cpu` (
  `id` int(11) NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `loadonemin` varchar(10) DEFAULT NULL,
  `loadtenmin` varchar(10) DEFAULT NULL,
  `loadfifmin` varchar(10) DEFAULT NULL,
  `x` varchar(10) NOT NULL,
  `y` varchar(10) NOT NULL,
  `importtime` varchar(255) NOT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `loggedusers`
--

CREATE TABLE `loggedusers` (
  `hostname` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `pts` varchar(10) NOT NULL,
  `date` varchar(20) NOT NULL,
  `time` varchar(20) NOT NULL,
  `ipaddr` varchar(50) NOT NULL,
  `random` varchar(255) NOT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `hist_loggedusers`
--

CREATE TABLE `hist_loggedusers` (
  `hostname` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `pts` varchar(10) DEFAULT NULL,
  `date` varchar(20) DEFAULT NULL,
  `time` varchar(20) DEFAULT NULL,
  `ipaddr` varchar(50) DEFAULT NULL
  `importtime` varchar(255) NOT NULL,
  `random` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `srv`
--

CREATE TABLE `srv` (
  `id` int(11) NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `lastping` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `hist_srv`
--

CREATE TABLE `hist_srv` (
  `random` varchar(255) NOT NULL,
  `id` int(11) NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `lastping` varchar(255) DEFAULT NULL,
  `importtime` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Indexes for table `apachestatus`
--
ALTER TABLE `apachestatus`
  ADD PRIMARY KEY (`id`);
  
--
-- Indexes for table `hist_apachestatus`
--
ALTER TABLE `hist_apachestatus`
  ADD PRIMARY KEY (`importtime`);
  
-- --------------------------------------------------------

--
-- Indexes for table `cpu`
--
ALTER TABLE `cpu`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hist_cpu`
--
ALTER TABLE `hist_cpu`
  ADD PRIMARY KEY (`id`);

-- --------------------------------------------------------

--
-- Indexes for table `loggedusers`
--
ALTER TABLE `loggedusers`
  ADD PRIMARY KEY (`random`);
  
--
-- Indexes for table `hist_loggedusers`
--
ALTER TABLE `hist_loggedusers`
  ADD PRIMARY KEY (`random`);

-- --------------------------------------------------------

--
-- Indexes for table `srv`
--
ALTER TABLE `srv`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hist_srv`
--
ALTER TABLE `hist_srv`
  ADD PRIMARY KEY (`random`);

-- --------------------------------------------------------
