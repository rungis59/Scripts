CREATE UNIQUE INDEX VEH_ENTE_I2 ON VEH_ENTE
(NUM_INT_TRA)
LOGGING
NOPARALLEL;

CREATE UNIQUE INDEX VEH_ENTE_I3 ON VEH_ENTE
(NUM_INT_TRT)
LOGGING
NOPARALLEL;

CREATE INDEX VEH_TRSP_I1 ON VEH_TRSP
(NUM_VEH)
LOGGING
NOPARALLEL;
