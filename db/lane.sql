-- ============================================================
-- Toll.Architect — lane.sql
-- ============================================================


-- ------------------------------------------------------------
-- Infrastructure
-- ------------------------------------------------------------

CREATE TABLE public.lane_configuration
(
    id             uuid         NOT NULL DEFAULT uuidv4(),
    sys_date       timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update     timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible    bool         NOT NULL DEFAULT true,
    sys_enabled    bool         NOT NULL DEFAULT true,
    code_district  varchar(20)  NOT NULL,
    name_district  varchar(100) NOT NULL,
    code_plaza     varchar(20)  NOT NULL,
    name_plaza     varchar(100) NOT NULL,
    code_subplaza  varchar(20)  NOT NULL,
    name_subplaza  varchar(100) NOT NULL,
    direction      varchar(50)  NOT NULL,
    physical_lanes smallint     NOT NULL,
    origin         varchar(100) NOT NULL,
    destination    varchar(100) NOT NULL,
    code_lane      varchar(20)  NOT NULL,
    CONSTRAINT lane_configuration_pk PRIMARY KEY (id)
);

CREATE TABLE public.carriageways
(
    id                    uuid         NOT NULL DEFAULT uuidv4(),
    sys_date              timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update            timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible           bool         NOT NULL DEFAULT true,
    sys_enabled           bool         NOT NULL DEFAULT true,
    lane_configuration_id uuid         NOT NULL,
    code                  varchar(20)  NOT NULL,
    toll_booth            varchar(50)  NOT NULL,
    direction             varchar(50)  NOT NULL,
    CONSTRAINT carriageways_pk PRIMARY KEY (id),
    CONSTRAINT carriageways_lane_configuration_fk
        FOREIGN KEY (lane_configuration_id) REFERENCES public.lane_configuration (id)
);
CREATE INDEX carriageways_lane_configuration_id_idx ON public.carriageways (lane_configuration_id);


-- ------------------------------------------------------------
-- Users & Profiles
-- ------------------------------------------------------------

CREATE TABLE public.profiles
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        varchar(20)  NOT NULL,
    name        varchar(100) NOT NULL,
    CONSTRAINT profiles_pk PRIMARY KEY (id)
);

CREATE TABLE public.profile_permissions
(
    profile_id uuid        NOT NULL,
    permission varchar(50) NOT NULL,
    CONSTRAINT profile_permissions_pk PRIMARY KEY (profile_id, permission),
    CONSTRAINT profile_permissions_profile_fk
        FOREIGN KEY (profile_id) REFERENCES public.profiles (id)
);
CREATE INDEX profile_permissions_profile_id_idx ON public.profile_permissions (profile_id);

CREATE TABLE public.users
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    profile_id  uuid         NOT NULL,
    username    varchar(20)  NOT NULL,
    first_name  varchar(100) NOT NULL,
    last_name   varchar(100) NOT NULL,
    expires_at  timestamp    NOT NULL,
    employee_id varchar(50)  NOT NULL,
    password    varchar(255) NOT NULL,
    CONSTRAINT users_pk PRIMARY KEY (id),
    CONSTRAINT users_employee_id_un UNIQUE (employee_id),
    CONSTRAINT users_username_un    UNIQUE (username),
    CONSTRAINT users_profile_fk     FOREIGN KEY (profile_id) REFERENCES public.profiles (id)
);
CREATE INDEX users_profile_id_idx ON public.users (profile_id);


-- ------------------------------------------------------------
-- Shifts
-- ------------------------------------------------------------

CREATE TABLE public.shifts
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        smallint     NOT NULL,
    name        varchar(100) NOT NULL,
    start_time  time(0)      NOT NULL,
    end_time    time(0)      NOT NULL,
    CONSTRAINT shifts_pk PRIMARY KEY (id)
);

CREATE TABLE public.shift_leaders
(
    id              uuid      NOT NULL DEFAULT uuidv4(),
    sys_date        timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible     bool      NOT NULL DEFAULT true,
    sys_enabled     bool      NOT NULL DEFAULT true,
    shift_id        uuid      NOT NULL,
    user_id         uuid      NOT NULL,
    assignment_date date      NOT NULL,
    CONSTRAINT shift_leaders_pk       PRIMARY KEY (id),
    CONSTRAINT shift_leaders_shift_fk FOREIGN KEY (shift_id) REFERENCES public.shifts (id),
    CONSTRAINT shift_leaders_user_fk  FOREIGN KEY (user_id)  REFERENCES public.users (id)
);
CREATE INDEX shift_leaders_shift_id_idx ON public.shift_leaders (shift_id);
CREATE INDEX shift_leaders_user_id_idx  ON public.shift_leaders (user_id);

CREATE TABLE public.cashier_assignments
(
    id              uuid      NOT NULL DEFAULT uuidv4(),
    sys_date        timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible     bool      NOT NULL DEFAULT true,
    sys_enabled     bool      NOT NULL DEFAULT true,
    user_id         uuid      NOT NULL,
    shift_leader_id uuid      NOT NULL,
    CONSTRAINT cashier_assignments_pk               PRIMARY KEY (id),
    CONSTRAINT cashier_assignments_user_fk          FOREIGN KEY (user_id)         REFERENCES public.users (id),
    CONSTRAINT cashier_assignments_shift_leader_fk  FOREIGN KEY (shift_leader_id) REFERENCES public.shift_leaders (id)
);
CREATE INDEX cashier_assignments_user_id_idx         ON public.cashier_assignments (user_id);
CREATE INDEX cashier_assignments_shift_leader_id_idx ON public.cashier_assignments (shift_leader_id);


-- ------------------------------------------------------------
-- Catalogs
-- ------------------------------------------------------------

CREATE TABLE public.lane_states
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        varchar(20)  NOT NULL,
    category    varchar(50)  NOT NULL,
    description varchar(255) NOT NULL,
    CONSTRAINT lane_states_pk PRIMARY KEY (id)
);

CREATE TABLE public.payment_methods
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        varchar(20)  NOT NULL,
    name        varchar(100) NOT NULL,
    CONSTRAINT payment_methods_pk PRIMARY KEY (id),
    CONSTRAINT payment_methods_un UNIQUE (code)
);

CREATE TABLE public.currencies
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        char(3)      NOT NULL, -- ISO 4217
    name        varchar(100) NOT NULL,
    expires_at  timestamp    NOT NULL,
    CONSTRAINT currencies_pk PRIMARY KEY (id),
    CONSTRAINT currencies_un UNIQUE (code)
);

CREATE TABLE public.tax_rates
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    code        varchar(10)  NOT NULL,
    percentage  numeric(5,2) NOT NULL,
    description varchar(255) NOT NULL,
    CONSTRAINT tax_rates_pk PRIMARY KEY (id)
);

CREATE TABLE public.vehicle_classifications
(
    id                 uuid         NOT NULL DEFAULT uuidv4(),
    sys_date           timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update         timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible        bool         NOT NULL DEFAULT true,
    sys_enabled        bool         NOT NULL DEFAULT true,
    tariff_code        varchar(20)  NOT NULL,
    vehicle_class_code varchar(20)  NOT NULL,
    description        varchar(255) NOT NULL,
    CONSTRAINT vehicle_classifications_pk PRIMARY KEY (id)
);
CREATE INDEX vehicle_classifications_codes_idx ON public.vehicle_classifications (tariff_code, vehicle_class_code);


-- ------------------------------------------------------------
-- Rate structure
-- ------------------------------------------------------------

CREATE TABLE public.rate_tables
(
    id          uuid         NOT NULL DEFAULT uuidv4(),
    sys_date    timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update  timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible bool         NOT NULL DEFAULT true,
    sys_enabled bool         NOT NULL DEFAULT true,
    currency_id uuid         NOT NULL,
    tax_rate_id uuid         NOT NULL,
    code        varchar(20)  NOT NULL,
    expires_at  timestamp    NOT NULL,
    description varchar(255) NOT NULL,
    CONSTRAINT rate_tables_pk         PRIMARY KEY (id),
    CONSTRAINT rate_tables_un         UNIQUE (code),
    CONSTRAINT rate_tables_currency_fk  FOREIGN KEY (currency_id) REFERENCES public.currencies (id),
    CONSTRAINT rate_tables_tax_rate_fk  FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rates (id)
);
CREATE INDEX rate_tables_currency_id_idx ON public.rate_tables (currency_id);
CREATE INDEX rate_tables_tax_rate_id_idx ON public.rate_tables (tax_rate_id);

CREATE TABLE public.toll_rates
(
    id                        uuid          NOT NULL DEFAULT uuidv4(),
    sys_date                  timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update                timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible               bool          NOT NULL DEFAULT true,
    sys_enabled               bool          NOT NULL DEFAULT true,
    rate_table_id             uuid          NOT NULL,
    vehicle_classification_id uuid          NOT NULL,
    amount                    numeric(12,2) NOT NULL,
    CONSTRAINT toll_rates_pk                        PRIMARY KEY (id),
    CONSTRAINT toll_rates_rate_table_fk             FOREIGN KEY (rate_table_id)             REFERENCES public.rate_tables (id),
    CONSTRAINT toll_rates_vehicle_classification_fk FOREIGN KEY (vehicle_classification_id) REFERENCES public.vehicle_classifications (id)
);
CREATE INDEX toll_rates_rate_table_id_idx             ON public.toll_rates (rate_table_id);
CREATE INDEX toll_rates_vehicle_classification_id_idx ON public.toll_rates (vehicle_classification_id);

CREATE TABLE public.billing_configurations
(
    id                uuid      NOT NULL DEFAULT uuidv4(),
    sys_date          timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update        timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible       bool      NOT NULL DEFAULT true,
    sys_enabled       bool      NOT NULL DEFAULT true,
    rate_table_id     uuid      NOT NULL,
    payment_method_id uuid      NOT NULL,
    CONSTRAINT billing_configurations_pk                  PRIMARY KEY (id),
    CONSTRAINT billing_configurations_rate_table_fk       FOREIGN KEY (rate_table_id)     REFERENCES public.rate_tables (id),
    CONSTRAINT billing_configurations_payment_method_fk   FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods (id)
);
CREATE INDEX billing_configurations_rate_table_id_idx     ON public.billing_configurations (rate_table_id);
CREATE INDEX billing_configurations_payment_method_id_idx ON public.billing_configurations (payment_method_id);


-- ------------------------------------------------------------
-- Operations
-- ------------------------------------------------------------

CREATE TABLE public.shift_cuts
(
    id                    uuid         NOT NULL DEFAULT uuidv7(),
    sys_date              timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update            timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible           bool         NOT NULL DEFAULT true,
    sys_enabled           bool         NOT NULL DEFAULT true,
    sys_synchro           bool         NOT NULL DEFAULT false,
    cashier_assignment_id uuid         NOT NULL,
    carriageway_id        uuid         NOT NULL,
    lane_state_id         uuid         NOT NULL,
    start_time            timestamp    NOT NULL,
    end_time              timestamp    NULL,
    start_folio           varchar(50)  NOT NULL,
    end_folio             varchar(50)  NULL,
    observations          varchar(500) NULL,
    cut_sequence          int4         NOT NULL,
    CONSTRAINT shift_cuts_pk                     PRIMARY KEY (id),
    CONSTRAINT shift_cuts_cashier_assignment_fk  FOREIGN KEY (cashier_assignment_id) REFERENCES public.cashier_assignments (id),
    CONSTRAINT shift_cuts_carriageway_fk         FOREIGN KEY (carriageway_id)        REFERENCES public.carriageways (id),
    CONSTRAINT shift_cuts_lane_state_fk          FOREIGN KEY (lane_state_id)         REFERENCES public.lane_states (id)
);
CREATE INDEX shift_cuts_cashier_assignment_id_idx ON public.shift_cuts (cashier_assignment_id);
CREATE INDEX shift_cuts_carriageway_id_idx        ON public.shift_cuts (carriageway_id);
CREATE INDEX shift_cuts_lane_state_id_idx         ON public.shift_cuts (lane_state_id);
CREATE INDEX shift_cuts_start_time_idx            ON public.shift_cuts (start_time);

CREATE TABLE public.toll_transactions
(
    id                       uuid          NOT NULL DEFAULT uuidv7(),
    sys_date                 timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_update               timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sys_visible              bool          NOT NULL DEFAULT true,
    sys_enabled              bool          NOT NULL DEFAULT true,
    sys_synchro              bool          NOT NULL DEFAULT false,
    shift_cut_id             uuid          NOT NULL,
    billing_configuration_id uuid          NOT NULL,
    toll_rate_id             uuid          NOT NULL,
    ticket_number            varchar(50)   NOT NULL,
    folio_number             varchar(50)   NOT NULL,
    transaction_sequence     int4          NOT NULL,
    captured_at              timestamp     NOT NULL,
    tce_pre_classification   varchar(20)   NOT NULL,
    cashier_classification   varchar(20)   NOT NULL,
    tce_post_classification  varchar(20)   NULL,
    code_payment_method      varchar(20)   NOT NULL,
    subtotal                 numeric(12,2) NOT NULL DEFAULT 0,
    tax_amount               numeric(12,2) NOT NULL DEFAULT 0,
    is_reclassified          bool          NOT NULL DEFAULT false,
    is_manual                bool          NOT NULL DEFAULT false,
    has_discrepancy          bool          NOT NULL DEFAULT false,
    tag_number               varchar(50)   NULL,
    CONSTRAINT toll_transactions_pk                        PRIMARY KEY (id),
    CONSTRAINT toll_transactions_shift_cut_fk              FOREIGN KEY (shift_cut_id)             REFERENCES public.shift_cuts (id),
    CONSTRAINT toll_transactions_billing_configuration_fk  FOREIGN KEY (billing_configuration_id) REFERENCES public.billing_configurations (id),
    CONSTRAINT toll_transactions_toll_rate_fk              FOREIGN KEY (toll_rate_id)             REFERENCES public.toll_rates (id)
);
CREATE INDEX toll_transactions_shift_cut_id_idx             ON public.toll_transactions (shift_cut_id);
CREATE INDEX toll_transactions_billing_configuration_id_idx ON public.toll_transactions (billing_configuration_id);
CREATE INDEX toll_transactions_toll_rate_id_idx             ON public.toll_transactions (toll_rate_id);
CREATE INDEX toll_transactions_captured_at_idx              ON public.toll_transactions (captured_at);


-- ============================================================
-- Comments
-- ============================================================


-- ------------------------------------------------------------
-- Infrastructure
-- ------------------------------------------------------------

COMMENT ON TABLE public.lane_configuration IS
    'Identity of this lane installation. Contains a single row that defines which district, plaza, subplaza and physical lane this database instance belongs to. Populated once during lane commissioning.';

COMMENT ON COLUMN public.lane_configuration.sys_date    IS 'Record creation timestamp (UTC).';
COMMENT ON COLUMN public.lane_configuration.sys_update  IS 'Record last update timestamp (UTC).';
COMMENT ON COLUMN public.lane_configuration.sys_visible IS 'Soft visibility flag. False hides the record from application queries without deleting it.';
COMMENT ON COLUMN public.lane_configuration.sys_enabled IS 'Operational enable flag. False disables the record from business logic without deleting it.';

COMMENT ON COLUMN public.lane_configuration.code_district  IS 'Short identifier for the administrative district this lane belongs to.';
COMMENT ON COLUMN public.lane_configuration.code_plaza     IS 'Short identifier for the toll plaza (caseta).';
COMMENT ON COLUMN public.lane_configuration.name_plaza     IS 'Full display name of the toll plaza.';
COMMENT ON COLUMN public.lane_configuration.code_subplaza  IS 'Short identifier for the subplaza (road body / cuerpo).';
COMMENT ON COLUMN public.lane_configuration.name_subplaza  IS 'Full display name of the subplaza.';
COMMENT ON COLUMN public.lane_configuration.direction      IS 'Primary traffic direction of this subplaza (e.g. Norte-Sur).';
COMMENT ON COLUMN public.lane_configuration.physical_lanes IS 'Total number of physical lanes in this subplaza.';
COMMENT ON COLUMN public.lane_configuration.origin         IS 'Origin point of this road segment (e.g. city or km marker).';
COMMENT ON COLUMN public.lane_configuration.destination    IS 'Destination point of this road segment (e.g. city or km marker).';
COMMENT ON COLUMN public.lane_configuration.code_lane      IS 'Short identifier for this specific physical lane within the subplaza.';

COMMENT ON TABLE public.carriageways IS
    'Operational directions available for this lane. A lane can serve up to two carriageways (e.g. 1A towards city A, 1B towards city B) depending on traffic flow decisions. The active carriageway is recorded on each shift_cut.';

COMMENT ON COLUMN public.carriageways.lane_configuration_id IS 'Lane this carriageway belongs to.';
COMMENT ON COLUMN public.carriageways.code                  IS 'Short identifier for this carriageway (e.g. 1A, 1B).';
COMMENT ON COLUMN public.carriageways.toll_booth            IS 'Physical toll booth identifier associated with this carriageway.';
COMMENT ON COLUMN public.carriageways.direction             IS 'Traffic direction when this carriageway is active (e.g. Mexico-Queretaro).';


-- ------------------------------------------------------------
-- Users & Profiles
-- ------------------------------------------------------------

COMMENT ON TABLE public.profiles IS
    'User role definitions. Each profile groups a set of permissions that control what a user can do in the system. Permissions are stored separately in profile_permissions.';

COMMENT ON COLUMN public.profiles.code IS 'Short internal code for this profile (e.g. SL, CS, ADM).';
COMMENT ON COLUMN public.profiles.name IS 'Human-readable name of the profile (e.g. Shift Leader, Cashier).';

COMMENT ON TABLE public.profile_permissions IS
    'Permissions granted to a profile. Each row represents a single capability assigned to a profile. Adding a new permission requires only an INSERT, not a schema change.';

COMMENT ON COLUMN public.profile_permissions.profile_id  IS 'Profile that holds this permission.';
COMMENT ON COLUMN public.profile_permissions.permission  IS 'Permission key (e.g. cashier, maintenance, demo, contingency).';

COMMENT ON TABLE public.users IS
    'Operator accounts. Includes both cashiers (CS) and shift leaders (SL). Profile determines the role and permissions. Credentials are stored as a hashed password (argon2id); plaintext is never persisted.';

COMMENT ON COLUMN public.users.profile_id  IS 'Role assigned to this user.';
COMMENT ON COLUMN public.users.username    IS 'Login key used to authenticate within the system (e.g. 0001). Must be unique.';
COMMENT ON COLUMN public.users.first_name  IS 'User given name.';
COMMENT ON COLUMN public.users.last_name   IS 'User family name.';
COMMENT ON COLUMN public.users.expires_at  IS 'Date and time after which this account is no longer valid. Enforced by application logic.';
COMMENT ON COLUMN public.users.employee_id IS 'Identifier assigned by the external HR system. Used to correlate with payroll and personnel records.';
COMMENT ON COLUMN public.users.password    IS 'Argon2id hash of the user password. Never store plaintext. Length 255 accommodates any current or future hashing algorithm.';


-- ------------------------------------------------------------
-- Shifts
-- ------------------------------------------------------------

COMMENT ON TABLE public.shifts IS
    'Shift schedule definitions. Describes the time windows for each work shift (e.g. Morning 06:00-14:00). Used as a template when assigning shift leaders.';

COMMENT ON COLUMN public.shifts.code       IS 'Numeric identifier for the shift (e.g. 1 = Morning, 2 = Afternoon, 3 = Night).';
COMMENT ON COLUMN public.shifts.name       IS 'Display name of the shift (e.g. Matutino, Vespertino).';
COMMENT ON COLUMN public.shifts.start_time IS 'Scheduled start time for this shift (no date component).';
COMMENT ON COLUMN public.shifts.end_time   IS 'Scheduled end time for this shift (no date component).';

COMMENT ON TABLE public.shift_leaders IS
    'Assignment of a shift leader (SL profile) to a specific shift on a specific date. One shift leader is responsible for a lane on a given day and shift.';

COMMENT ON COLUMN public.shift_leaders.shift_id        IS 'Shift template this assignment is based on.';
COMMENT ON COLUMN public.shift_leaders.user_id         IS 'User with SL profile acting as shift leader.';
COMMENT ON COLUMN public.shift_leaders.assignment_date IS 'Calendar date for which this shift leader assignment is valid.';

COMMENT ON TABLE public.cashier_assignments IS
    'Assignment of cashier operators (CS profile) to a shift leader. One shift leader can have multiple cashiers under their supervision during a shift.';

COMMENT ON COLUMN public.cashier_assignments.user_id         IS 'Cashier operator being assigned.';
COMMENT ON COLUMN public.cashier_assignments.shift_leader_id IS 'Shift leader supervising this cashier.';


-- ------------------------------------------------------------
-- Catalogs
-- ------------------------------------------------------------

COMMENT ON TABLE public.lane_states IS
    'Catalog of possible operational states for a lane (e.g. Open, Closed, Maintenance). Used to record the state of the lane at the start of each shift cut.';

COMMENT ON COLUMN public.lane_states.code        IS 'Short code identifying the state (e.g. OP, CL, MN).';
COMMENT ON COLUMN public.lane_states.category    IS 'Grouping category for this state (e.g. operational, maintenance, contingency).';
COMMENT ON COLUMN public.lane_states.description IS 'Full human-readable description of the state.';

COMMENT ON TABLE public.payment_methods IS
    'Catalog of accepted payment methods (e.g. Cash, Credit Card, Electronic Tag). The code is used as a denormalized reference in toll_transactions for reporting performance.';

COMMENT ON COLUMN public.payment_methods.code IS 'Short unique identifier for this payment method. Referenced directly in toll_transactions.code_payment_method.';
COMMENT ON COLUMN public.payment_methods.name IS 'Display name of the payment method (e.g. Cash, IAVE, Credit Card).';

COMMENT ON TABLE public.currencies IS
    'Supported currencies for toll rate tables. Code follows ISO 4217 (3-character alphabetic code). expires_at indicates when a currency configuration should be reviewed or replaced.';

COMMENT ON COLUMN public.currencies.code       IS 'ISO 4217 three-character currency code (e.g. MXN, USD). Enforced as char(3).';
COMMENT ON COLUMN public.currencies.name       IS 'Full currency name (e.g. Mexican Peso, US Dollar).';
COMMENT ON COLUMN public.currencies.expires_at IS 'Date after which this currency configuration should be reviewed. Does not automatically disable it.';

COMMENT ON TABLE public.tax_rates IS
    'Tax rate configurations applicable to toll charges. Designed to support multiple tax types beyond VAT (e.g. special levies). Referenced by rate_tables.';

COMMENT ON COLUMN public.tax_rates.code        IS 'Short identifier for this tax rate (e.g. VAT16, EXEMPT).';
COMMENT ON COLUMN public.tax_rates.percentage  IS 'Tax percentage with two decimal places (e.g. 16.00 for 16% VAT).';
COMMENT ON COLUMN public.tax_rates.description IS 'Full description of this tax rate and its legal basis.';

COMMENT ON TABLE public.vehicle_classifications IS
    'Vehicle category definitions used for toll rate lookup. tariff_code represents the billing category; vehicle_class_code represents the physical classification as reported by the TCE (Traffic Controller Equipment).';

COMMENT ON COLUMN public.vehicle_classifications.tariff_code        IS 'Billing category code used to determine the applicable toll rate.';
COMMENT ON COLUMN public.vehicle_classifications.vehicle_class_code IS 'Physical vehicle class code as reported by the TCE sensor.';
COMMENT ON COLUMN public.vehicle_classifications.description        IS 'Human-readable description of this vehicle classification (e.g. Motorcycle, Car, Bus with 2 axles).';


-- ------------------------------------------------------------
-- Rate structure
-- ------------------------------------------------------------

COMMENT ON TABLE public.rate_tables IS
    'Toll rate table definitions. A rate table groups a set of toll_rates under a specific currency and tax rate configuration. Multiple rate tables can coexist; expires_at indicates until when a table is valid.';

COMMENT ON COLUMN public.rate_tables.currency_id IS 'Currency in which rates in this table are denominated.';
COMMENT ON COLUMN public.rate_tables.tax_rate_id IS 'Tax rate applied to all charges under this rate table.';
COMMENT ON COLUMN public.rate_tables.code        IS 'Unique short identifier for this rate table (e.g. RT-2024-MXN).';
COMMENT ON COLUMN public.rate_tables.expires_at  IS 'Date after which this rate table should no longer be used for new transactions.';
COMMENT ON COLUMN public.rate_tables.description IS 'Human-readable description of this rate table and its scope.';

COMMENT ON TABLE public.toll_rates IS
    'Individual toll amounts per vehicle classification within a rate table. Each row defines the charge for one vehicle class under a specific rate table.';

COMMENT ON COLUMN public.toll_rates.rate_table_id             IS 'Rate table this charge belongs to.';
COMMENT ON COLUMN public.toll_rates.vehicle_classification_id IS 'Vehicle classification this charge applies to.';
COMMENT ON COLUMN public.toll_rates.amount                    IS 'Toll amount before tax, with two decimal places.';

COMMENT ON TABLE public.billing_configurations IS
    'Junction table linking rate tables to accepted payment methods. Defines which payment methods are valid for a given rate table. Both columns are required — a billing configuration without a rate table or payment method has no business meaning.';

COMMENT ON COLUMN public.billing_configurations.rate_table_id     IS 'Rate table included in this billing configuration.';
COMMENT ON COLUMN public.billing_configurations.payment_method_id IS 'Payment method accepted under this billing configuration.';


-- ------------------------------------------------------------
-- Operations
-- ------------------------------------------------------------

COMMENT ON TABLE public.shift_cuts IS
    'Operational shift cuts (cortes de turno). Records the opening and closing of a cashier session on a specific carriageway. A shift cut captures the folio range, lane state, and timing for one continuous work period. Uses uuidv7 for natural chronological ordering.';

COMMENT ON COLUMN public.shift_cuts.sys_synchro           IS 'True once this record has been successfully synchronized to the central system.';
COMMENT ON COLUMN public.shift_cuts.cashier_assignment_id IS 'Cashier assignment active during this shift cut.';
COMMENT ON COLUMN public.shift_cuts.carriageway_id        IS 'Carriageway (direction) on which this shift cut was operated.';
COMMENT ON COLUMN public.shift_cuts.lane_state_id         IS 'Operational state of the lane at the start of this shift cut.';
COMMENT ON COLUMN public.shift_cuts.start_time            IS 'Timestamp when the shift cut was opened.';
COMMENT ON COLUMN public.shift_cuts.end_time              IS 'Timestamp when the shift cut was closed. NULL while the cut is still active.';
COMMENT ON COLUMN public.shift_cuts.start_folio           IS 'First folio number issued in this shift cut.';
COMMENT ON COLUMN public.shift_cuts.end_folio             IS 'Last folio number issued in this shift cut. NULL while the cut is still active.';
COMMENT ON COLUMN public.shift_cuts.observations          IS 'Optional free-text notes recorded by the shift leader at cut closing. NULL when no observations were made.';
COMMENT ON COLUMN public.shift_cuts.cut_sequence          IS 'Sequential counter of shift cuts within a cashier assignment, starting at 1.';

COMMENT ON TABLE public.toll_transactions IS
    'Individual toll collection events. Each row represents one vehicle passage and its associated charge. High-volume table — uses uuidv7 for chronological ordering and efficient range queries. Uses uuidv7 for natural chronological ordering.';

COMMENT ON COLUMN public.toll_transactions.sys_synchro              IS 'True once this record has been successfully synchronized to the central system.';
COMMENT ON COLUMN public.toll_transactions.shift_cut_id             IS 'Shift cut during which this transaction was captured.';
COMMENT ON COLUMN public.toll_transactions.billing_configuration_id IS 'Billing configuration (rate table + payment method) applied to this transaction.';
COMMENT ON COLUMN public.toll_transactions.toll_rate_id             IS 'Specific toll rate applied, which determines the vehicle classification and amount.';
COMMENT ON COLUMN public.toll_transactions.ticket_number            IS 'Ticket identifier printed or issued to the vehicle at collection time.';
COMMENT ON COLUMN public.toll_transactions.folio_number             IS 'Sequential folio number within the active shift cut.';
COMMENT ON COLUMN public.toll_transactions.transaction_sequence     IS 'Sequential counter of transactions within the shift cut, starting at 1.';
COMMENT ON COLUMN public.toll_transactions.captured_at              IS 'Business timestamp of the vehicle passage. Distinct from sys_date (record creation time).';
COMMENT ON COLUMN public.toll_transactions.tce_pre_classification   IS 'Vehicle class reported by the TCE (Traffic Controller Equipment) before the vehicle reaches the booth.';
COMMENT ON COLUMN public.toll_transactions.cashier_classification   IS 'Vehicle class assigned by the cashier operator at collection time.';
COMMENT ON COLUMN public.toll_transactions.tce_post_classification  IS 'Vehicle class reported by the TCE after the vehicle passes the booth. NULL if the TCE did not produce a post-read.';
COMMENT ON COLUMN public.toll_transactions.code_payment_method      IS 'Denormalized copy of payment_methods.code for reporting performance. Must stay in sync with the referenced billing_configuration.';
COMMENT ON COLUMN public.toll_transactions.subtotal                 IS 'Toll amount before tax.';
COMMENT ON COLUMN public.toll_transactions.tax_amount               IS 'Tax amount applied to this transaction.';
COMMENT ON COLUMN public.toll_transactions.is_reclassified          IS 'True if the vehicle classification was changed after initial capture.';
COMMENT ON COLUMN public.toll_transactions.is_manual                IS 'True if this transaction was entered manually, bypassing automatic TCE classification.';
COMMENT ON COLUMN public.toll_transactions.has_discrepancy          IS 'True if the tce_pre_classification, cashier_classification, or tce_post_classification values do not agree.';
COMMENT ON COLUMN public.toll_transactions.tag_number               IS 'Electronic tag identifier (e.g. IAVE, TeleVia). NULL for vehicles without an electronic tag.';
