import { Genre } from "./genre.model";

export interface Track {
    id?: string;
    title?: string;
    artist?: string;
    releaseYear?: number;
    explicit?: boolean;
    duration?: number;
    genres?: Genre[];
}