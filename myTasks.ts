import { task } from 'hardhat/config';
import champions from './scripts/tasks/champions';
import mint from './scripts/tasks/mint';
import upgrade_to from './scripts/tasks/upgrade_to';

task('task_champions', 'Champions check balance task').setAction(champions);
task('task_mint', 'mint test task').setAction(mint);
task('task_upgrade_to', 'upgrade proxy address task').setAction(upgrade_to);
